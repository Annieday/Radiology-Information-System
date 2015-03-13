<HTML>
<HEAD><TITLE>Analysis Page</TITLE></HEAD>
<BODY background="BGP.jpg">
	<%@ page import="java.sql.*"%>
	<%!
		public Connection getConnection(String oracleId,String oraclePassword){
			Connection con = null;
			String driverName = "oracle.jdbc.driver.OracleDriver";
			String dbstring = "jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";
			try{
				Class drvClass = Class.forName(driverName);
				DriverManager.registerDriver((Driver)drvClass.newInstance());
				con=DriverManager.getConnection(dbstring,oracleId,oraclePassword);
				con.setAutoCommit(true);
			}
			catch(Exception e){
				
			}
			return con;
		}
	%>
	<%!
		public String getExtra(String patientID,String testType,String fDate,String tDate){
			if(patientID.equals("") && testType.equals("") && fDate.equals("") && tDate.equals("")){
				return " ";
			}
			else if(patientID.equals("")==false && testType.equals("") && fDate.equals("") && tDate.equals("")){
				return " AND rr.patient_id="+patientID+" ";
			}
			else if(patientID.equals("") && testType.equals("")==false && fDate.equals("") && tDate.equals("")){
				return " AND rr.test_type='"+testType+"' ";
			}
			else if(patientID.equals("") && testType.equals("") && fDate.equals("")==false && tDate.equals("")==false){
				return " AND rr.test_date>='"+fDate+"' AND "+"rr.test_date<='"+tDate+"' ";
			}
			else if(patientID.equals("")==false && testType.equals("")==false && fDate.equals("") && tDate.equals("")){
				return " AND rr.patient_id="+patientID+" AND "+"rr.test_type='"+testType+"' ";
			}
			else if(patientID.equals("")==false && testType.equals("") && fDate.equals("")==false && tDate.equals("")==false){
				return " AND rr.patient_id="+patientID+" AND rr.test_date>='"+fDate+"' AND "+"rr.test_date<='"+tDate+"' ";
			}
			else if(patientID.equals("") && testType.equals("")==false && fDate.equals("")==false && tDate.equals("")==false){
				return " AND rr.test_type='"+testType+"' AND rr.test_date>='"+fDate+"' AND "+"rr.test_date<='"+tDate+"' ";
			}
			else{
				return " AND rr.patient_id="+patientID+" AND rr.test_type='"+testType+"' AND rr.test_date>='"+fDate+"' AND rr.test_date<='"+tDate+"' ";
			}
		}
	%>
	<%!
		public void setDateFormat(Connection con) throws SQLException{
			String sql="alter SESSION set NLS_DATE_FORMAT = 'MM/DD/YYYY'";
			Statement s=con.createStatement();
			s.executeQuery(sql);
		}
	%>
	<%
		if(request.getParameter("StartAnalysis")==null){
			response.sendRedirect("Connector.html");
		}
	
		out.println("<H1><CENTER>Data Analysis Result: </CENTER></H1>");
		out.println("<HR></HR>");
	
		String patientID=request.getParameter("patientID");
		String testType=request.getParameter("testType");
		String fDate=request.getParameter("fDate");
		String tDate=request.getParameter("tDate");
		if((fDate.equals("") && (tDate.equals("")==false))||((fDate.equals("")==false) && tDate.equals(""))){
			response.sendRedirect("Analysis.jsp");
		}
		//---------------------------------------------------
		String groupRangeOption=request.getParameter("groupByRange");
		String groupByPatient=request.getParameter("GroupByPatient");
		String groupByTestType=request.getParameter("GroupByTestType");
	
		Connection con=getConnection((String)session.getAttribute("ORACLE_ID"),(String)session.getAttribute("ORACLE_PASSWORD"));
	
		setDateFormat(con);
	
		Statement s =con.createStatement();
		//-------------------------------------------------------------Conditions
		String ps=null;String ts=null;String rs=null;
		if(patientID.equals("")){
			ps="not selected";
		}
		else{
			String query="SELECT p.first_name,p.last_name FROM persons p WHERE p.person_id="+patientID;
			ResultSet res=s.executeQuery(query);
			while(res.next()){
				ps=res.getString("first_name")+" "+res.getString("last_name")+" (ID: "+patientID+")";
			}
		}
		//--
		if(testType.equals("")){
			ts="not selected";
		}
		else{
			ts=testType;
		}
		//--
		if(fDate.equals("")&&tDate.equals("")){
			rs="None";
		}
		else{
			rs="From "+fDate+" To "+tDate+" (MM-DD-YYYY)";
		}
		out.println("<CENTER><H4><font color=Maroon>Patient : "+ps+" ; Test Type: "+ts+" ; Time Range: "+rs+"</font></H4></CENTER>");
		out.println("<HR></HR>");
		//-------------------------------------------------------------
		ResultSet resSet=null;
		String sql=null;
		String extra=getExtra(patientID,testType,fDate,tDate);
		
		//Group By None
		if(groupByPatient==null && groupByTestType==null && groupRangeOption.equals("")){
			sql="SELECT count(*) AS CNT "+
				"FROM pacs_images pi,radiology_record rr "+
				"WHERE pi.record_id=rr.record_id"+extra;
			
			resSet=s.executeQuery(sql);
			
			out.println("<TABLE style='margin: 0px auto'>");
			while(resSet.next()){
				int count=resSet.getInt("CNT");
				out.println("<H3><CENTER> Total number of images is "+count+" </CENTER></H3>");
			}
			out.println("</TABLE>");
		}
		
		//Group By patient
		else if(groupByPatient!=null && groupByTestType==null && groupRangeOption.equals("")){
			sql="SELECT count(*) AS CNT,p.first_name,p.last_name,rr.patient_id "+
				"FROM pacs_images pi,radiology_record rr,persons p "+
				"WHERE pi.record_id=rr.record_id AND "+
					  "rr.patient_id=p.person_id"+extra+
				"GROUP BY p.first_name,p.last_name,rr.patient_id";
			
			resSet=s.executeQuery(sql);
			
			out.println("<TABLE style='margin: 0px auto'>");
			while(resSet.next()){
				int count=resSet.getInt("CNT");
				int pid=resSet.getInt("patient_id");
				String fname=resSet.getString("first_name");
				String lname=resSet.getString("last_name");
				out.println("<H3><CENTER> Total number of images with patient: "+fname+" "+lname+"(id: "+pid+") is "+count+" </CENTER></H3>");
			}
			out.println("</TABLE>");
		}
		
		//Group By testType
		else if(groupByPatient==null && groupByTestType!=null && groupRangeOption.equals("")){
			sql="SELECT count(*) AS CNT,rr.test_type "+
				"FROM pacs_images pi,radiology_record rr "+
				"WHERE rr.record_id=pi.record_id"+extra+
				"GROUP BY rr.test_type";
			
			resSet=s.executeQuery(sql);
			
			out.println("<TABLE style='margin: 0px auto'>");
			while(resSet.next()){
				int count=resSet.getInt("CNT");
				String type=resSet.getString("test_type");
				out.println("<H3><CENTER> Total number of images with test type: "+type+" is "+count+" </CENTER></H3>");
			}
			out.println("</TABLE>");
		}
		
		//Group By patient and testType
		else if(groupByPatient!=null && groupByTestType!=null && groupRangeOption.equals("")){
			sql="SELECT count(*) AS CNT,p.first_name,p.last_name,rr.patient_id,rr.test_type "+
				"FROM persons p,pacs_images pi,radiology_record rr "+
			    "WHERE p.person_id=rr.patient_id AND "+
					 "rr.record_id=pi.record_id"+extra+
				"GROUP BY p.first_name,p.last_name,rr.patient_id,rr.test_type";
			
			resSet=s.executeQuery(sql);
			
			out.println("<TABLE style='margin: 0px auto'>");
			while(resSet.next()){
				int count=resSet.getInt("CNT");
				int pid=resSet.getInt("patient_id");
				String fname=resSet.getString("first_name");
				String lname=resSet.getString("last_name");
				String type=resSet.getString("test_type");
				out.println("<H3><CENTER> Total number of images with test type: "+type+" and patient "+fname+" "+lname+"(id: "+pid+") is: "+count+" </CENTER></H3>");
			}
			out.println("</TABLE>");
		}
		
		//Group By time
		else if(groupByPatient==null && groupByTestType==null && groupRangeOption.equals("")==false){
			
			if(groupRangeOption.equals("year")){
				sql="SELECT count(*) AS CNT,EXTRACT(YEAR FROM rr.test_date) AS Y "+
					"FROM pacs_images pi,radiology_record rr "+
				    "WHERE rr.record_id=pi.record_id"+extra+
				    "GROUP BY EXTRACT(YEAR FROM rr.test_date)";
				
				resSet=s.executeQuery(sql);
				out.println("<TABLE style='margin: 0px auto'>");
				while(resSet.next()){
					int count=resSet.getInt("CNT");
					String year=resSet.getString("Y");
					out.println("<TR><TD>Total number of images group by year "+year+" is "+count+"</TD></TR>");
				}
				out.println("</TABLE>");
			}
			else if(groupRangeOption.equals("month")){
				sql="SELECT count(*) AS CNT,EXTRACT(YEAR FROM rr.test_date) AS Y,EXTRACT(MONTH FROM rr.test_date) AS M "+
					"FROM pacs_images pi,radiology_record rr "+
					"WHERE rr.record_id=pi.record_id"+extra+
					"GROUP BY EXTRACT(YEAR FROM rr.test_date),EXTRACT(MONTH FROM rr.test_date)";
					
				resSet=s.executeQuery(sql);
				out.println("<TABLE style='margin: 0px auto'>");
				while(resSet.next()){
					int count=resSet.getInt("CNT");
					String year=resSet.getString("Y");
					String month=resSet.getString("M");
					out.println("<TR><TD>Total number of images group by year/month "+year+"/"+month+" is "+count+"</TD></TR>");
				}
				out.println("</TABLE>");
			}
			else{
				sql="SELECT count(*) AS CNT,EXTRACT(YEAR FROM rr.test_date) AS Y,EXTRACT(MONTH FROM rr.test_date) AS M,to_char(rr.test_date,'w') AS W "+
					"FROM pacs_images pi,radiology_record rr "+
					"WHERE rr.record_id=pi.record_id"+extra+
					"GROUP BY EXTRACT(YEAR FROM rr.test_date),EXTRACT(MONTH FROM rr.test_date),to_char(rr.test_date,'w')";
				resSet=s.executeQuery(sql);
				out.println("<TABLE style='margin: 0px auto'>");
				while(resSet.next()){
					int count=resSet.getInt("CNT");
					String year=resSet.getString("Y");
					String month=resSet.getString("M");
					String week=resSet.getString("W");
					out.println("<TR><TD>Total number of images group by year/month/week "+year+"/"+month+"/"+week+" is "+count+"</TD></TR>");
				}
				out.println("</TABLE>");
			}
		}
		
		//Group By time and patient
		else if(groupByPatient!=null && groupByTestType==null && groupRangeOption.equals("")==false){
			if(groupRangeOption.equals("year")){
				sql="SELECT count(*) AS CNT,EXTRACT(YEAR FROM rr.test_date) AS Y,p.first_name,p.last_name,p.person_id "+
					"FROM persons p,radiology_record rr,pacs_images pi "+
					"WHERE rr.record_id=pi.record_id AND "+
						  "rr.patient_id=p.person_id"+extra+
					"GROUP BY EXTRACT(YEAR FROM rr.test_date),p.first_name,p.last_name,p.person_id";
						
				resSet=s.executeQuery(sql);
				out.println("<TABLE style='margin: 0px auto'>");
				while(resSet.next()){
					int count=resSet.getInt("CNT");
					String year=resSet.getString("Y");
					String fname=resSet.getString("first_name");
					String lname=resSet.getString("last_name");
					int id=resSet.getInt("person_id");
					out.println("<TR><TD>Total number of images group by year: "+year+" with the patient: "+fname+" "+lname+"(ID: "+id+") is "+count+"</TD></TR>");
				}
				out.println("</TABLE>");
			}
					
			else if(groupRangeOption.equals("month")){
				sql="SELECT count(*) AS CNT,EXTRACT(YEAR FROM rr.test_date) AS Y,EXTRACT(MONTH FROM rr.test_date) AS M,p.first_name,p.last_name,p.person_id "+
					"FROM persons p,radiology_record rr,pacs_images pi "+
					"WHERE rr.record_id=pi.record_id AND "+
						  "rr.patient_id=p.person_id"+extra+
					"GROUP BY EXTRACT(YEAR FROM rr.test_date),EXTRACT(MONTH FROM rr.test_date),p.first_name,p.last_name,p.person_id";
						
				resSet=s.executeQuery(sql);
				out.println("<TABLE style='margin: 0px auto'>");
				while(resSet.next()){
					int count=resSet.getInt("CNT");
					String year=resSet.getString("Y");
					String month=resSet.getString("M");
					String fname=resSet.getString("first_name");
					String lname=resSet.getString("last_name");
					int id=resSet.getInt("person_id");
					out.println("<TR><TD>Total number of images group by year/month: "+year+"/"+month+" with the patient: "+fname+" "+lname+"(ID: "+id+") is "+count+"</TD></TR>");
				}
				out.println("</TABLE>");
			}
			else{
				sql="SELECT count(*) AS CNT,EXTRACT(YEAR FROM rr.test_date) AS Y,EXTRACT(MONTH FROM rr.test_date) AS M,to_char(rr.test_date,'w') AS W,p.first_name,p.last_name,p.person_id "+
					"FROM pacs_images pi,radiology_record rr,persons p "+
					"WHERE rr.record_id=pi.record_id AND "+
						  "rr.patient_id=p.person_id"+extra+
					"GROUP BY EXTRACT(YEAR FROM rr.test_date),EXTRACT(MONTH FROM rr.test_date),to_char(rr.test_date,'w'),p.first_name,p.last_name,p.person_id";
							
				resSet=s.executeQuery(sql);
				out.println("<TABLE style='margin: 0px auto'>");
				while(resSet.next()){
					int count=resSet.getInt("CNT");
					String year=resSet.getString("Y");
					String month=resSet.getString("M");
					String week=resSet.getString("W");
					String fname=resSet.getString("first_name");
					String lname=resSet.getString("last_name");
					int id=resSet.getInt("person_id");
					out.println("<TR><TD>Total number of images group by year/month/week "+year+"/"+month+"/"+week+" with the person: "+fname+" "+lname+"(id: "+id+") is "+count+"</TD></TR>");
				}
				out.println("</TABLE>");
			}
		}
		
		//Group By time and type
		else if(groupByPatient==null && groupByTestType!=null && groupRangeOption.equals("")==false){
			if(groupRangeOption.equals("year")){
				sql="SELECT count(*) AS CNT,EXTRACT(YEAR FROM rr.test_date) AS Y,rr.test_type "+
					"FROM pacs_images pi,radiology_record rr "+
			        "WHERE rr.record_id=pi.record_id"+extra+
					"GROUP BY EXTRACT(YEAR FROM rr.test_date),rr.test_type";
				
				resSet=s.executeQuery(sql);
				out.println("<TABLE style='margin: 0px auto'>");
				while(resSet.next()){
					int count=resSet.getInt("CNT");
					String year=resSet.getString("Y");
					String type=resSet.getString("test_type");
					out.println("<TR><TD>Total number of images group by year:"+year+" with the test type:"+type+" is "+count+"</TD></TR>");
				}
				out.println("</TABLE>");
			}
			else if(groupRangeOption.equals("month")){
				sql="SELECT count(*) AS CNT,EXTRACT(YEAR FROM rr.test_date) AS Y,EXTRACT(MONTH FROM rr.test_date) AS M,rr.test_type "+
					"FROM pacs_images pi,radiology_record rr "+
					"WHERE rr.record_id=pi.record_id"+extra+
					"GROUP BY EXTRACT(YEAR FROM rr.test_date),EXTRACT(MONTH FROM rr.test_date),rr.test_type";
				
				resSet=s.executeQuery(sql);
				out.println("<TABLE style='margin: 0px auto'>");
				while(resSet.next()){
					int count=resSet.getInt("CNT");
					String year=resSet.getString("Y");
					String month=resSet.getString("M");
					String type=resSet.getString("test_type");
					out.println("<TR><TD>Total number of images group by year/month: "+year+"/"+month+" with the test type: "+type+" is "+count+"</TD></TR>");
				}
				out.println("</TABLE>");
			}
			else if(groupRangeOption.equals("week")){
				sql="SELECT count(*) AS CNT,EXTRACT(YEAR FROM rr.test_date) AS Y,EXTRACT(MONTH FROM rr.test_date) AS M,to_char(rr.test_date,'w') AS W,rr.test_type "+
					"FROM pacs_images pi,radiology_record rr "+
					"WHERE rr.record_id=pi.record_id"+extra+
					"GROUP BY EXTRACT(YEAR FROM rr.test_date),EXTRACT(MONTH FROM rr.test_date),to_char(rr.test_date,'w'),rr.test_type";
				
				resSet=s.executeQuery(sql);
				out.println("<TABLE style='margin: 0px auto'>");
				while(resSet.next()){
					int count=resSet.getInt("CNT");
					String year=resSet.getString("Y");
					String month=resSet.getString("M");
					String week=resSet.getString("W");
					String type=resSet.getString("test_type");
					out.println("<TR><TD>Total number of images group by year/month/week "+year+"/"+month+"/"+week+" with the test type: "+type+" is "+count+"</TD></TR>");
				}
					
				out.println("</TABLE>");
			}
		}
		//Group By ALL
		else if(groupByPatient!=null && groupByTestType!=null && groupRangeOption.equals("")==false){
				if(groupRangeOption.equals("year")){
					sql="SELECT count(*) AS CNT,EXTRACT(YEAR FROM rr.test_date) AS Y,p.first_name,p.last_name,p.person_id,rr.test_type "+
						"FROM persons p,radiology_record rr,pacs_images pi "+
						"WHERE rr.record_id=pi.record_id AND "+
							  "rr.patient_id=p.person_id"+extra+
						"GROUP BY EXTRACT(YEAR FROM rr.test_date),p.first_name,p.last_name,p.person_id,rr.test_type";
						
					resSet=s.executeQuery(sql);
					out.println("<TABLE style='margin: 0px auto'>");
					while(resSet.next()){
						int count=resSet.getInt("CNT");
						String year=resSet.getString("Y");
						String fname=resSet.getString("first_name");
						String lname=resSet.getString("last_name");
						int id=resSet.getInt("person_id");
						String type=resSet.getString("test_type");
						out.println("<TR><TD>Total number of images group by year: "+year+" with the patient: "+fname+" "+lname+"(ID: "+id+") test type : "+type+" is "+count+"</TD></TR>");
					}
					out.println("</TABLE>");
				}
					
				else if(groupRangeOption.equals("month")){
					sql="SELECT count(*) AS CNT,EXTRACT(YEAR FROM rr.test_date) AS Y,EXTRACT(MONTH FROM rr.test_date) AS M,p.first_name,p.last_name,p.person_id,rr.test_type "+
						"FROM persons p,radiology_record rr,pacs_images pi "+
						"WHERE rr.record_id=pi.record_id AND "+
							  "rr.patient_id=p.person_id"+extra+
						"GROUP BY EXTRACT(YEAR FROM rr.test_date),EXTRACT(MONTH FROM rr.test_date),p.first_name,p.last_name,p.person_id,rr.test_type";
						
					resSet=s.executeQuery(sql);
					out.println("<TABLE style='margin: 0px auto'>");
					while(resSet.next()){
						int count=resSet.getInt("CNT");
						String year=resSet.getString("Y");
						String month=resSet.getString("M");
						String fname=resSet.getString("first_name");
						String lname=resSet.getString("last_name");
						int id=resSet.getInt("person_id");
						String type=resSet.getString("test_type");
						out.println("<TR><TD>Total number of images group by year/month: "+year+"/"+month+" with the patient: "+fname+" "+lname+"(ID: "+id+") test type : "+type+" is "+count+"</TD></TR>");
					}
					out.println("</TABLE>");
			    }
				else{
					sql="SELECT count(*) AS CNT,EXTRACT(YEAR FROM rr.test_date) AS Y,EXTRACT(MONTH FROM rr.test_date) AS M,to_char(rr.test_date,'w') AS W,p.first_name,p.last_name,p.person_id,rr.test_type "+
						"FROM pacs_images pi,radiology_record rr,persons p "+
						"WHERE rr.record_id=pi.record_id AND "+
							  "rr.patient_id=p.person_id"+extra+
						"GROUP BY EXTRACT(YEAR FROM rr.test_date),EXTRACT(MONTH FROM rr.test_date),to_char(rr.test_date,'w'),rr.test_type,p.first_name,p.last_name,p.person_id";
								
					resSet=s.executeQuery(sql);
					out.println("<TABLE style='margin: 0px auto'>");
					while(resSet.next()){
						int count=resSet.getInt("CNT");
						String year=resSet.getString("Y");
						String month=resSet.getString("M");
						String week=resSet.getString("W");
						String fname=resSet.getString("first_name");
						String lname=resSet.getString("last_name");
						String type=resSet.getString("test_type");
						int id=resSet.getInt("person_id");
						out.println("<TR><TD>Total number of images group by year/month/week "+year+"/"+month+"/"+week+" with the person: "+fname+" "+lname+"(id: "+id+") test type: "+type+" is "+count+"</TD></TR>");
					}
									
					out.println("</TABLE>");
				}
		}
		
		con.close();
	%>
	<FORM NAME='ReturnForm' ACTION='Analysis.jsp' METHOD='get'>
	<CENTER><INPUT TYPE='submit' NAME='AnalysisRequest' VALUE='RETURN'></CENTER>
	</FORM>
</BODY>
</HTML>
