package stormapplied.radio;

import java.util.Map;

import stormapplied.radio.Tweet;
import weka.core.DenseInstance;
import weka.core.Instance;
import weka.core.Instances;
import org.apache.storm.task.OutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.topology.base.BaseRichBolt;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Tuple;
import org.apache.storm.tuple.Values;

/**
 * 
 * Bolt that collects stream tuples and turns them into an instance object
 * so they are can be processed by weka and moa classes
 * 
 * 
 */
public class InstanceBolt extends BaseRichBolt {

	private static final long serialVersionUID = -290300387298901098L;
	private OutputCollector _collector;
	private final Instances INST_HEADERS;
	static String filename= "resources/category.txt";

	
	public InstanceBolt(Instances instHeaders){
		INST_HEADERS = instHeaders;
	}


	@Override
	public void declareOutputFields(OutputFieldsDeclarer declarer) {
		declarer.declare(new Fields("tweetInstance"));
	}

	@Override
	public void prepare(Map stormConf, TopologyContext context,
			OutputCollector collector) {
		_collector = collector;
	}

	@Override
	public void execute(Tuple input) {
		
		String sentence = input.getStringByField("text");
		String label = input.getStringByField("category");
		
	
		//Turn it into an instance
		Instance inst = new DenseInstance(2);
		
		inst.setDataset(INST_HEADERS);
		
		inst.setValue(0, sentence);
		
		if(label.contains("sports/enter")){
        
			inst.setClassValue(1);
			
		}else{
			
			inst.setClassValue(0);
		}

		//emit these to a new bolt that collects instances
		_collector.emit(input,new Values(inst));
		_collector.ack(input);
		
		
	}

}
