package stormapplied.radio;

import java.util.Map;

import weka.core.Instances;
import weka.core.SparseInstance;

import moa.classifiers.Classifier;
import moa.classifiers.meta.OzaBoost;
import moa.core.InstancesHeader;
import moa.options.ClassOption;

import org.apache.storm.task.OutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseRichBolt;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Tuple;
import org.apache.storm.tuple.Values;

/**
 * 
 * OzaBoostBolt that runs instances through a OzaBoost instances for moa
 * 
 * 
 *
 */
public class OzaBoostBolt extends BaseRichBolt {
	
	private final OzaBoost classifier;
	private OutputCollector collector;
	private InstancesHeader INST_HEADERS;

	private static final long serialVersionUID = 5699756297412652215L;
	
	public OzaBoostBolt(String classifierName){
		classifier = new OzaBoost();
		classifier.baseLearnerOption = new ClassOption("baseLearner", 'l',"Classifier to train.",Classifier.class, classifierName);
		classifier.prepareForUse();
	}

	@Override
	public void prepare(Map stormConf, TopologyContext context,	OutputCollector collector) {
		this.collector = collector;
	}

	@Override
	public void execute(Tuple input) {
		
		Object obj = input.getValue(0);
		
		//If we get the headers set them and reset
		if(obj.getClass() == Instances.class){
			INST_HEADERS = new InstancesHeader((Instances) obj);
			classifier.setModelContext(INST_HEADERS);
			classifier.resetLearningImpl();
		}else{
			SparseInstance inst = (SparseInstance) obj;
			//Emit the entire prediction array and the correct value
			collector.emit(input,new Values(classifier.getVotesForInstance(inst), inst.classValue()));
			//Train on instance
			classifier.trainOnInstanceImpl(inst);
		}
		
		collector.ack(input);
	}

	@Override
	public void declareOutputFields(OutputFieldsDeclarer declarer) {
		declarer.declare(new Fields("votesForInstance","actualClass"));
	}

}
