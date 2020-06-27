package stormapplied.radio;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


import stormapplied.radio.StatsWriterBolt;
import stormapplied.radio.StatsPrinterBolt;
import stormapplied.radio.StatisticsBolt;
import stormapplied.radio.OzaBoostBolt;
import stormapplied.radio.StringToWordVectorBolt2;

import org.apache.storm.Config;
import org.apache.storm.LocalCluster;
import org.apache.storm.StormSubmitter;
import org.apache.storm.metric.LoggingMetricsConsumer;
import org.apache.storm.topology.BoltDeclarer;
import org.apache.storm.topology.TopologyBuilder;
import org.apache.storm.tuple.Values;
import stormapplied.radio.LineReaderSpout;
import weka.core.Attribute;
import weka.core.Instances;
import stormapplied.radio.InstanceBolt;


public class sampleTopolgy {
	
 	
	public static void main(String[] args) throws Exception{
		
		final int STAT_RES = 1;
		final int FILTER_SET_SIZE = 1600;
		final int WORDS_TO_KEEP = 8000;
		ArrayList<String> label = new ArrayList<String>();
		label.add("others");
		label.add("sports/enter");
			
		ArrayList<Attribute> att = new ArrayList<Attribute>();
		att.add(new Attribute("text", (List<String>)null, 0));
		att.add(new Attribute("category", label, 1));
		Instances instHeaders = new Instances("tweet",att, 10);
		instHeaders.setClassIndex(1);
		
		Config config = new Config();
		//config.setDebug(true);
		config.setNumWorkers(1);
		//config.setNumAckers(2);
		//config.setStatsSampleRate(1.0d);

		config.put(Config.TOPOLOGY_MAX_SPOUT_PENDING, 100);
		config.put(Config.TOPOLOGY_TRANSFER_BUFFER_SIZE,32);
	    config.put(Config.TOPOLOGY_EXECUTOR_RECEIVE_BUFFER_SIZE,16384);
	    config.put(Config.TOPOLOGY_EXECUTOR_SEND_BUFFER_SIZE,16384);



		TopologyBuilder builder = new TopologyBuilder();
		
		BoltDeclarer instanceBolt = builder.setBolt("instancebolt", new InstanceBolt(instHeaders),1);
		String resultsFolder = ((Long)System.currentTimeMillis()).toString();
		
		
		resultsFolder = String.format("[%s]", label) + resultsFolder;
		
		builder.setSpout("line-reader-spout", new LineReaderSpout2(),1);
		instanceBolt.shuffleGrouping("line-reader-spout");
		builder.setBolt("stringToWordBolt", new StringToWordVectorBolt2(FILTER_SET_SIZE, WORDS_TO_KEEP),1).shuffleGrouping("instancebolt");
		builder.setBolt("ozaBoostBolt:naiveBayesMultinomial", new OzaBoostBolt("bayes.NaiveBayesMultinomial"),1).shuffleGrouping("stringToWordBolt");
		builder.setBolt("statistics:naiveBayesMultinomial", new StatisticsBolt(label.size(),STAT_RES),1).shuffleGrouping("ozaBoostBolt:naiveBayesMultinomial");
		builder.setBolt("StatsPrinterBolt:naiveBayesMultinomial", new StatsPrinterBolt("naiveBayesMultinominal")).shuffleGrouping("statistics:naiveBayesMultinomial");
		builder.setBolt("StatsWriterBolt:naiveBayesMultinomial", new StatsWriterBolt("naiveBayesMultinominal", resultsFolder)).shuffleGrouping("statistics:naiveBayesMultinomial"); 
		
	 	LocalCluster cluster = new LocalCluster();
		//StormSubmitter.submitTopology("sampleTopolgy", config, builder.createTopology());
 		cluster.submitTopology("sampleTopolgy", config, builder.createTopology());
 			 
		Thread.sleep(10000);
		
		//cluster.shutdown();
	}

}

