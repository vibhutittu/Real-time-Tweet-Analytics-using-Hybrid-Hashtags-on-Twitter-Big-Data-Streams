package stormapplied.radio;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.storm.spout.SpoutOutputCollector;
import org.apache.storm.task.TopologyContext;
import org.apache.storm.topology.IRichSpout;
import org.apache.storm.topology.OutputFieldsDeclarer;
import org.apache.storm.tuple.Fields;
import org.apache.storm.tuple.Values;
import org.apache.storm.utils.Utils;

public class LineReaderSpout2 implements IRichSpout {
	private SpoutOutputCollector collector;
	private FileReader fileReader;
	private int nextEmitIndex;
	private boolean completed = false;
	private TopologyContext context;
	private Integer msgId;
	Map<Integer, List<String>> sentTuples = new HashMap<Integer, List<String>>();
	String filename= "resources/combined_ont_hashtags_data.csv";
	
	
	
	public void open(Map conf, TopologyContext context,
            SpoutOutputCollector collector) {
            try {
            this.context = context;
            this.msgId = 0;
            this.nextEmitIndex = 0;
            this.sentTuples = new HashMap<Integer, List<String>>();
            File file = new File(filename);
            this.fileReader = new FileReader(file);
        } catch (FileNotFoundException e) {
            throw new RuntimeException("Error reading file ["+ filename + "]");
        }
        this.collector = collector;
    }

	@Override
	public void nextTuple() {
		String str;
		BufferedReader reader = new BufferedReader(fileReader);
		try {
			
			while ((str = reader.readLine()) != null) {
				List<String> values = new ArrayList<String>();
				
				String tmp[] = str.split(",");
			    msgId++;

				collector.emit(new Values(tmp[0],tmp[1]),msgId);
				values.add(tmp[0]);
				values.add(tmp[1]);
			    sentTuples.put(msgId, values);

				
			}
		} catch (Exception e) {
			throw new RuntimeException("Error reading typle", e);
		} finally {
			completed = true;
		}

	}
	
	
	
	
	@Override
	public void declareOutputFields(OutputFieldsDeclarer declarer) {
		declarer.declare(new Fields("text","category"));
	}

	@Override
	public void close() {
		try {
			fileReader.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	public boolean isDistributed() {
		return false;
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