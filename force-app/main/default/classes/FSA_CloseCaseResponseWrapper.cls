public class FSA_CloseCaseResponseWrapper{
	public String parentId; //NOT USED
    public String Id;
    public String transfercase;
	public String add_info;
    public String caseClosure;
    public String startTime;
    public String endTime;
    public String ambId;
            public String endLocation;
	public boolean showEndLocation;
    
	public cls_imageData[] imageData;
    
	public class cls_imageData {
		public String fileName;	
		public String image;
	}
	
}