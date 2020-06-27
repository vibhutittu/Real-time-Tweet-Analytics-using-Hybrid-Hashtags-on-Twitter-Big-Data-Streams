package stormapplied.radio;


import java.io.Serializable;

/**
 * Implementation of a tweet post
 * 
 *
 */
public class Tweet implements Serializable {
	
	/**
	 * Generated serialVersionUID
	 */
	private static final long serialVersionUID = -1176274406450812313L;
	private String tweet;
	private String label;
	
	/**
	 * Creates a new Tweet object
	 * @param tweet The tweet of the post
	 * @param label The class the post came from
	 */
	public Tweet(String tweet, String label){
		this.tweet = tweet;
		this.label = label;
	}
	
	/**
	 * Creates an empty Tweet object
	 */
	public Tweet(){}
	
	/**
	 * Gets the label the post came from
	 * @return The label of the post
	 */
	public String getLabel(){
		return this.label;
	}

	/**
	 * Gets the Tweet of the post
	 * @return The Tweet of the post
	 */
	public String getTweet(){
		return this.tweet;
	}
	
	/**
	 * Sets the tweet the post came from
	 * @param tweet label
	 */
	public void setLabel(String label){
		this.label = label;
	}
	
	/**
	 * Sets the title of the post
	 * @param title The title of the post to set
	 */
	public void setTweet(String tweet){
		this.tweet = tweet;
	}
	
	@Override
	public String toString(){
		return String.format("%s [%s]", this.tweet, this.label);
	}

}
