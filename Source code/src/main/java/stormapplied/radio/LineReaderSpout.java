package stormapplied.radio;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.storm.utils.Utils;

import stormapplied.radio.Tweet;

import org.apache.storm.shade.org.apache.commons.io.IOUtils;
import org.apache.storm.spout.SpoutOutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.IRichSpout;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Values;

public class LineReaderSpout implements IRichSpout {
	private SpoutOutputCollector collector;
	private FileReader fileReader;
	private int nextEmitIndex;
	private boolean completed = false;
	private TopologyContext context;
	private int spout_id;
	private List<String> checkins;
	private Integer msgId;
	Map<Integer, List<String>> sentTuples = new HashMap<Integer, List<String>>();

	String filename= "resources/combined_ont_hashtags_data.csv";
	
	
	
	public void open(Map conf, TopologyContext context,
            SpoutOutputCollector collector) {
           this.collector = collector;
           this.context = context;
           this.nextEmitIndex = 0;
           this.msgId = 0;
           this.sentTuples = new HashMap<Integer, List<String>>();
           try {

        	   checkins = IOUtils
			            .readLines(new InputStreamReader(new FileInputStream(filename), "utf-8"));

        	    } catch (IOException e) {

        	      throw new RuntimeException(e);

        	    }
    }

	@Override
	public void nextTuple() {
		
		List<String> values = new ArrayList<String>();
        
		String checkin = checkins.get(nextEmitIndex);
		String tmp[] = checkin.split(",");
	    String text = tmp[0];
        String txtclass = tmp[1];
        msgId++;
        
		collector.emit(new Values(text,txtclass),msgId);
		values.add(text);
		values.add(txtclass);
		
		
		

		
		//Store the sentTuple until ack is received
	    sentTuples.put(msgId, values);
	    nextEmitIndex = (nextEmitIndex + 1) % checkins.size();

	}
	
	
	
	
	@Override
	public void declareOutputFields(OutputFieldsDeclarer declarer) {
		declarer.declare(new Fields("text","category"));
	}

	@Override
	public void close() {
		
	}
	public boolean isDistributed() {
		return true;
	}
	@Override
	public void activate() {
	}
	@Override
	public void deactivate() {
	}
	
	@Override
	public void ack(Object msgId) {
		
		sentTuples.remove(msgId);
     }
	
	@Override
	public void fail(Object msgId) {
		
	List<String> var = sentTuples.get(msgId);
	String txt = var.get(0).toString();
	String txtclass = var.get(1).toString();
	collector.emit(new Values(txt,txtclass),msgId);


		
    }
	
	@Override
	public Map<String, Object> getComponentConfiguration() {
		return null;
	}
}