<HTML>
<HEAD>
<TITLE>Upload Process</TITLE>
</HEAD>
<BODY>
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
		public int get_person_id(Connection con,String email){
			String sqlStatement="SELECT person_id FROM persons WHERE email='"+email+"'";
			Statement s=null;
			ResultSet resSet=null;
			Integer personId=null;
			try{
				s=con.createStatement();
				resSet=s.executeQuery(sqlStatement);
				while(resSet != null && resSet.next()){
					personId=(resSet.getInt("person_id"));
				}
			}
			catch(Exception e){

			}
			return personId;
		}
	%>

	<%!
		public int get_rad_id(Connection con,String userName){
			String sqlStatement="SELECT person_id FROM users WHERE user_name='"+userName+"'";
			Statement s=null;
			ResultSet resSet=null;
			Integer personId=null;
				 try{
					s=con.createStatement();
					resSet=s.executeQuery(sqlStatement);
					while(resSet != null && resSet.next()){
						personId=(resSet.getInt("person_id"));
					}
				}
				catch(Exception e){
        		        
				}
			return personId;
		}
	%>

	<%!
		public int get_next_recId(Connection con){
			String sqlStatement="SELECT MAX(record_id) FROM radiology_record";
			Statement s=null;
			ResultSet resSet=null;
			Integer maxId=null;
			try{
				s=con.createStatement();
				resSet=s.executeQuery(sqlStatement);
				while(resSet != null && resSet.next()){
					maxId=(resSet.getInt(1));
				}
			}
			catch(Exception e){
			}
			if(maxId==null){
				maxId=0;
			}
			return maxId+1;
		}
	%>

	<%@ page import="java.sql.*"%>

	<%
			Connection con=null;
			Integer recordId=null;
			if(request.getParameter("CommitUploadRecord") != null){
				String oracleId=(String)session.getAttribute("ORACLE_ID");
				String oraclePassword=(String)session.getAttribute("ORACLE_PASSWORD");
        		
				String testType=(request.getParameter("testType")).trim();
        		
				String prescribing_date=(request.getParameter("pDate")).trim();

				String test_date=(request.getParameter("tDate")).trim();
        		
				String diagnosis=(request.getParameter("diagnosis")).trim();
        		
				String description=(request.getParameter("description")).trim();
        		
				String userName=(String)session.getAttribute("USERNAME");
        		//----------------------------------------------------------------
        		con=getConnection(oracleId,oraclePassword);
				if(con==null){
					out.println("<p><b>Unable to Connect Oracle DB!</b></p>");
					out.println("<p><b>Invalid UserName or Password!</b></p>");
					out.println("<p><b>Press RETURN to the previous page.</b></p>");
					out.println("<FORM NAME='ConnectFailForm' ACTION='Connector.html' METHOD='get'>");
					out.println("    <CENTER><INPUT TYPE='submit' NAME='CONNECTION_FAIL' VALUE='RETURN'></CENTER>");
					out.println("</FORM>");
				}
				else{
					String patientId=request.getParameter("patientID");
					String doctorId=request.getParameter("doctorID");
					recordId=get_next_recId(con);
					int radId=get_rad_id(con,userName);
					String sqlStatement1 = "alter SESSION set NLS_DATE_FORMAT = 'MM/DD/YYYY'";

					String sqlStatement2 = "INSERT INTO radiology_record VALUES("+recordId+","+patientId+","+doctorId+","
					+radId+",'"+testType+"','"+prescribing_date+"','"+test_date+"','"+diagnosis+"','"+description+"')";

					Statement s=con.createStatement();
					Boolean failed=false;
					try{
						s.executeQuery(sqlStatement1);
						s.executeQuery(sqlStatement2);
					}
					catch(Exception e){
						failed=true;
						out.println("<p><b>Invalid Upload.</b></p>");
						out.println("<FORM NAME='UploadFailForm' ACTION='RadPage.jsp' METHOD='get'>");
						out.println("    <CENTER><INPUT TYPE='submit' NAME='RETURN' VALUE='RETURN'></CENTER>");
						out.println("</FORM>");
					}
					con.close();
					if(failed==false){
						session.removeAttribute("CURRENT_REC_ID");
						session.setAttribute("CURRENT_REC_ID",recordId);
						response.sendRedirect("UploadPic.jsp");
					}
				}
			}
	%>
</BODY>
</HTML>
