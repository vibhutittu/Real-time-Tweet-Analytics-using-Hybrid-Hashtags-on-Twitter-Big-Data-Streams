package stormapplied.radio;

import java.util.Map;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.Semaphore;

import weka.attributeSelection.AttributeSelection;
import weka.attributeSelection.BestFirst;
import weka.attributeSelection.CfsSubsetEval;
import weka.attributeSelection.GainRatioAttributeEval;
import weka.attributeSelection.GreedyStepwise;
import weka.attributeSelection.InfoGainAttributeEval;
import weka.attributeSelection.Ranker;
import weka.attributeSelection.ReliefFAttributeEval;
import weka.attributeSelection.SymmetricalUncertAttributeEval;
import weka.classifiers.meta.FilteredClassifier;
import weka.core.DenseInstance;
import weka.core.Instance;
import weka.core.Instances;
import weka.filters.Filter;
import weka.filters.unsupervised.attribute.StringToWordVector;

import org.apache.storm.spout.SpoutOutputCollector;
import org.apache.storm.task.OutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseRichBolt;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Tuple;
import org.apache.storm.tuple.Values;

/**
 * Takes string instances and turns them into word vectors
 * 
 * @author Luke Barnett 1109967
 * @author Tony Chen 1111377
 *
 */
public class StringToWordVectorBolt2 extends BaseRichBolt{

	private static final long serialVersionUID = -7494062164103601417L;
	private final int BATCH_SIZE;
	private final int MAX_NUMBER_OF_WORDS_TO_KEEP;
	private Instances INST_HEADERS;
	private final ArrayBlockingQueue<Instance> BATCH_QUEUE;
    private OutputCollector collector;
	private Semaphore semaphore;
	private StringToWordVector filter;
	private Boolean training = true;
	
	public StringToWordVectorBolt2(int batchSize, int maxNumberOfWordsToKeep){
		//We need to have a batch size that is at least 1
		if(batchSize < 1){
			throw new IllegalArgumentException("Batch Size is less than 1");
		}
		if(maxNumberOfWordsToKeep < 1){
			throw new IllegalArgumentException("Max number of words to keep is less than 1");
		}
		
		//Store all the variables we need and set things up
		MAX_NUMBER_OF_WORDS_TO_KEEP = maxNumberOfWordsToKeep;
		BATCH_SIZE = batchSize;
		BATCH_QUEUE = new ArrayBlockingQueue<Instance>(BATCH_SIZE);

	//	INST_HEADERS = instHeaders;
		semaphore = new Semaphore(1);
		filter = new StringToWordVector(MAX_NUMBER_OF_WORDS_TO_KEEP);
		filter.setOutputWordCounts(true);
	}

	@Override
	public void declareOutputFields(OutputFieldsDeclarer declarer) {
		declarer.declare(new Fields("StringVectors"));
		
	}

	@Override
	public void prepare(Map stormConf, TopologyContext context,	OutputCollector collector) {
		this.collector = collector;
		
	}

	@Override
	public void execute(Tuple input) {
		//Get the instance
		DenseInstance inst = (DenseInstance) input.getValue(0);
		//System.out.println("print bolt inst"+inst);
		INST_HEADERS = inst.dataset();
		
		//Retrieve the semaphore
		try {
			semaphore.acquire();
		} catch (InterruptedException e2) {
			e2.printStackTrace();
		}
		
		
		/*
		 * If we are training then we add it to the batch until it's full
		 * At which point the model is created and we just stream instances through the model
		 */
		if(training){
			try{
				BATCH_QUEUE.add(inst);
				System.out.println("entered  ");
			}catch(IllegalStateException e){
				//Queue is full so we should train the filter
				try {
					
					//Add all the instances to the batch
					Instances data = new Instances(INST_HEADERS);
					
					for(Instance i : BATCH_QUEUE){
						data.add(i);
					}
					
					filter.setInputFormat(data);

					//Run the model creation
					Instances filter_training_set = Filter.useFilter(data, filter);		
					
					/* weka.filters.supervised.attribute.AttributeSelection selector = new weka.filters.supervised.attribute.AttributeSelection();
					  CfsSubsetEval eval = new CfsSubsetEval();
					  BestFirst search = new BestFirst();					  
					  selector.setEvaluator(eval);
					  selector.setSearch(search);*/
					 
					weka.filters.supervised.attribute.AttributeSelection selector = new weka.filters.supervised.attribute.AttributeSelection();
					
				    InfoGainAttributeEval eval = new InfoGainAttributeEval();
				    //GainRatioAttributeEval eval = new GainRatioAttributeEval();

				    selector.setEvaluator(eval);
				    Ranker search = new Ranker();
				    search.setThreshold(0);
                    selector.setSearch(search);
                    
				    
					 //Set up the filter
					 selector.setInputFormat(filter_training_set);
					 Instances newData=Filter.useFilter(filter_training_set, selector);

                        
					 
					//emit the instances used to train the filter
					for(int i=0; i<newData.numInstances(); i++){
						collector.emit(new Values(newData.get(i)));

					}

				 	training = false;
					//Empty the queue for memories
					BATCH_QUEUE.clear();
				} catch (Exception e1) {
					e1.printStackTrace();
				}
				
			}
		}else{
			//Filter through the model and emit
			try {
				
				filter.input(inst);
			} catch (Exception e) {
				e.printStackTrace();
			}
			
			Instance filteredValue;
			while((filteredValue = filter.output()) != null){
				collector.emit(new Values(filteredValue)); 

			}
			
		}
		
		//Always acknowledge the tuple we have processed so it isn't sent somewhere else
		collector.ack(input);
		semaphore.release();
	}

}









