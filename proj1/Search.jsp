<HTML>
<HEAD>
<TITLE>Search Handler</TITLE>
<!--Adapted from http://jqueryui.com/datepicker/#date-range-->
<link rel="stylesheet"
	href="//code.jquery.com/ui/1.10.4/themes/smoothness/jquery-ui.css">
<script src="//code.jquery.com/jquery-1.9.1.js"></script>
<script src="//code.jquery.com/ui/1.10.4/jquery-ui.js"></script>
<link rel="stylesheet" href="/resources/demos/style.css">
<style>
.from {
	
}

.to {
	
}
</style>
<script>
	$(function() {
		$(".from").datepicker({
			defaultDate : "+1w",
			changeMonth : true,
			changeYear : true,
			onClose : function(selectedDate) {
				$(".to").datepicker("option", "minDate", selectedDate);
			}
		});
		$(".to").datepicker({
			defaultDate : "+1w",
			changeMonth : true,
			changeYear : true,
			onClose : function(selectedDate) {
				$(".from").datepicker("option", "maxDate", selectedDate);
			}
		});
	});
</script>
</HEAD>
<BODY background="BGP.jpg">
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
	<%@ page import="java.sql.*"%>
	<%@ page import="java.util.*"%>
	<%
		String userName=null;
		if(request.getParameter("SearchRequest") != null 
			|| request.getParameter("CommitSearch") != null){
			userName = (String)session.getAttribute("USERNAME");
		}
		else{
			response.sendRedirect("Login.html");
		}
     %>

	<H1>
		<font color=Teal>Please Enter the Information to Search: </font>
	</H1>
	<BR></BR>
	<BR></BR>
	<b>You will get the list of all patients with a specified diagnosis
		for a given time period.</b>
	<FORM NAME="search_form" ACTION="Search.jsp" METHOD="post">
		<TABLE>
			<TR>
				<TD><B><I><font color=Maroon>Search keys: </TD>
				<TD style="width: 205px;"><INPUT TYPE="text" NAME="search_key"
					VALUE="" style="width: 194px;">*</TD>
			</TR>
			<TR>
				<TD><B><I><font color=Maroon>Time
								period(MM-DD-YYYY): </font></I></B></TD>
				<TD><label for="from">From</label> <INPUT TYPE="text"
					class="from" NAME="from" /></TD>
				<TD><label for="to">To</label> <INPUT TYPE="text" class="to"
					NAME="to" /></TD>

			</TR>

		</TABLE>

		*use comma to separate keys <br> Order by: <select
			NAME="OPERATION">
			<option VALUE="most-recent-last" SELECTED>Most-recent-last</option>
			<option VALUE="most_recent_first" SELECTED>Most-recent-first</option>
			<option VALUE="default" SELECTED>Default</option>
		</select> <input TYPE="submit" NAME="CommitSearch" VALUE="Search"><br>
		

		<%
          Connection con=null;
          if (request.getParameter("CommitSearch") != null)
          {

            if(!(request.getParameter("search_key").equals("")&&
              request.getParameter("from").equals("") &&
              request.getParameter("to").equals("")))
            {

				String op = request.getParameter("OPERATION").trim();
            	if(request.getParameter("search_key").equals("") && op.equals("default")){
            		out.println("<br><b>Can't order by Default if there is no search key</b>");
            	}
				else{
					String dropFullname = "DROP TABLE fullname";
	            	String crFullname = "CREATE TABLE fullname AS "
	            			+"(SELECT person_id, CONCAT(CONCAT(first_name,' '),last_name) as full_name FROM persons)";
	            	String crIndexName = "CREATE INDEX name ON fullname(full_name) INDEXTYPE IS CTXSYS.CONTEXT";
	            	String sqlString = "";
	                String from = "";
					String to = "";
					String search_key = "";
					String oracleId=(String)session.getAttribute("ORACLE_ID");
					String oraclePassword=(String)session.getAttribute("ORACLE_PASSWORD");
					String personID = (String)session.getAttribute("person_id");
					
					if(request.getParameter("search_key").equals("")){
				    	sqlString = "SELECT DISTINCT r.record_id,r.patient_id, r.doctor_id, r.radiologist_id,"
				    			+"r.test_type, r.test_date, r.prescribing_date,r.diagnosis, r.description "
				    			+"FROM radiology_record r WHERE ";
				    	if(((String)session.getAttribute("class")).equals("a")){
						}
						else if(((String)session.getAttribute("class")).equals("d")){
						    sqlString = sqlString +"r.doctor_id = "+personID+" AND ";
						}
						else if(((String)session.getAttribute("class")).equals("r")){
						    sqlString = sqlString +"r.radiologist_id = "+personID+" AND ";
						}
						else if(((String)session.getAttribute("class")).equals("p")){
						    sqlString = sqlString +"r.patient_id = "+personID+" AND ";
						}
						if(!(request.getParameter("from").equals(""))){
						    from = (String)request.getParameter("from");
						    sqlString = sqlString + "r.test_date >= to_date('"+from+"','MM/DD/YYYY') ";
						}
						if(!(request.getParameter("to").equals(""))){
						 	to = (String)request.getParameter("to");
							sqlString = sqlString + "r.test_date <= to_date('"+to+"','MM/DD/YYYY') ";
						}
				    }
				    else{
				    	search_key = (String)request.getParameter("search_key");
				    	sqlString = "SELECT s.rank, r.record_id, r.patient_id, r.doctor_id, r.radiologist_id, r.test_type,"
				    			+"r.test_date, r.prescribing_date, r.diagnosis, r.description "
				    			+"FROM radiology_record r, (SELECT DISTINCT max(score(1)*6 + score(2)*3 + score(3)) as rank,"
				    			+"r1.record_id FROM radiology_record r1, fullname f "
				    			+"WHERE CONTAINS(f.full_name,'"+search_key+"',1)>0 or CONTAINS(r1.diagnosis,'"+search_key+"',2) >0 "
				    			+"or CONTAINS(r1.description,'"+search_key+"',3)>0 "
				    			+"AND f.person_id = r1.patient_id GROUP BY r1.record_id) s WHERE r.record_id = s.record_id ";
				    	if(((String)session.getAttribute("class")).equals("a")){
						   		sqlString = sqlString + "";
							}
						else if(((String)session.getAttribute("class")).equals("d")){
						    sqlString = sqlString +"AND r.doctor_id = "+personID+" ";
						}
						    
						else if(((String)session.getAttribute("class")).equals("r")){
						    sqlString = sqlString +"AND r.radiologist_id = "+personID+" ";
						}
						else if(((String)session.getAttribute("class")).equals("p")){
						    sqlString = sqlString +"AND r.patient_id = "+personID+" ";
						}
						    
						if(!(request.getParameter("from").equals(""))){
						    from = (String)request.getParameter("from");
						    sqlString = sqlString + "AND r.test_date >= to_date('"+from+"','MM/DD/YYYY') ";
						}
						if(!(request.getParameter("to").equals(""))){
						 	to = (String)request.getParameter("to");
							sqlString = sqlString + "AND r.test_date <= to_date('"+to+"','MM/DD/YYYY') ";
						}
				    }

				    if(op.equals("most_recent_first")){
				    	sqlString = sqlString + "ORDER BY test_date desc";
				    }
				    else if(op.equals("most-recent-last")){
				    	sqlString = sqlString + "ORDER BY test_date";
				    }
				    else if(op.equals("default")){
				   		sqlString = sqlString + "ORDER BY rank desc ";
				    }
					con = getConnection(oracleId,oraclePassword);
					if(con==null){
						out.println("<p><b>Unable to Connect Oracle DB!</b></p>");
						out.println("<p><b>Invalid UserName or Password!</b></p>");
						out.println("<p><b>Press RETURN to the previous page.</b></p>");
						out.println("<FORM NAME='ConnectFailForm' ACTION='Connector.html' METHOD='get'>");
						out.println("    <CENTER><INPUT TYPE='submit' NAME='CONNECTION_FAIL' VALUE='RETURN'></CENTER>");
						out.println("</FORM>");
					}
					else{
						try{
							PreparedStatement setTimeFormat = con.prepareStatement("alter SESSION set NLS_DATE_FORMAT = 'MM/DD/YYYY'");
							setTimeFormat.executeQuery();
							PreparedStatement dropTableName = con.prepareStatement(dropFullname);
							PreparedStatement createTableName = con.prepareStatement(crFullname);
							createTableName.executeQuery();
							PreparedStatement createIndexName = con.prepareStatement(crIndexName);
							createIndexName.executeQuery();
							PreparedStatement takeImageID = con.prepareStatement("select image_id from pacs_images where record_id = ?");
							PreparedStatement doGenerate = con.prepareStatement(sqlString);
							ResultSet rset2 = doGenerate.executeQuery();
							ResultSet imageID = null;
							out.println("<br>");
						  	out.println("<br>");
						  	if(!(request.getParameter("search_key").equals("") || 
						  			request.getParameter("from").equals("") ||
								    request.getParameter("to").equals("")))
								out.println("All report with "+search_key+" key words during test date "+from+" and "+to+":");
						  	else if(request.getParameter("search_key").equals("") && 
						  			request.getParameter("from").equals(""))
						  		out.println("All report upto test date "+to+":");
						  	else if(request.getParameter("search_key").equals("") && 
						  			request.getParameter("to").equals(""))
						  		out.println("All report from test date "+from+":");
						  	else
						  		out.println("All report with "+search_key+" key words:");
						  	out.println("<br>");
						  	out.println("*date format is MM/DD/YYYY");
						  	out.println("<br>");
						  	out.println("*click on the thumbnail to see details");
						  	out.println("<br>");
							out.println("<table border=1>");
							out.println("<tr>");
							if(!request.getParameter("search_key").equals(""))
								out.println("<th>Rank</th>");
							out.println("<th>Record ID</th>");
							out.println("<th>Patient ID</th>");
							//out.println("<th>Patient Name</th>");
							out.println("<th>Doctor ID</th>");
							//out.println("<th>Doctor Name</th>");
							out.println("<th>Radiologist ID</th>");
							//out.println("<th>Radiologist Name</th>");
							out.println("<th>Test Type</th>");
							out.println("<th>Test Date*</th>");
							out.println("<th>Prescribing Date*</th>");
							out.println("<th>Diagnosis*</th>");
							out.println("<th>Description</th>");
							out.println("<th>Thumbnail Record Photos*</th>");
							out.println("</tr>");
	
							if(!request.getParameter("search_key").equals(""))
								while(rset2.next()){
									
									out.println("<tr>");
									out.println("<td>"); 
									out.println(rset2.getInt(1));
									out.println("</td>");
									out.println("<td>"); 
									out.println(rset2.getInt(2));
									out.println("</td>");
									out.println("<td>"); 
									out.println(rset2.getInt(3)); 
									out.println("</td>");
									out.println("<td>");
									out.println(rset2.getInt(4));
									out.println("</td>");
									out.println("<td>");
									out.println(rset2.getInt(5));
									out.println("</td>");
									out.println("<td>");
									out.println(rset2.getString(6));
									out.println("</td>");
									out.println("<td>");
									out.println(rset2.getDate(7));
									out.println("</td>");
									out.println("<td>");
									out.println(rset2.getDate(8));
									out.println("</td>");
									out.println("<td>");
									out.println(rset2.getString(9));
									out.println("</td>");
									out.println("<td>");
									out.println(rset2.getString(10));
									out.println("</td>");
									out.println("<td>");
									//for pictures~
									takeImageID.setInt(1,rset2.getInt(2));
									imageID = takeImageID.executeQuery();
									while(imageID.next()){
										out.println("<a href='ZoomPic.jsp?picID="+rset2.getInt(2)+"-"+imageID.getInt(1)+"' target='_blank'><img src='GetOnePic?t"+rset2.getInt(2)+"-"+imageID.getInt(1)+"'> </a>");
									}
									out.println("</td>");
									out.println("</tr>");
								}
							else
								while(rset2.next()){
									out.println("<tr>");
									out.println("<td>"); 
									out.println(rset2.getInt(1));
									out.println("</td>");
									out.println("<td>"); 
									out.println(rset2.getInt(2)); 
									out.println("</td>");
									out.println("<td>");
									out.println(rset2.getInt(3));
									out.println("</td>");
									out.println("<td>");
									out.println(rset2.getInt(4));
									out.println("</td>");
									out.println("<td>");
									out.println(rset2.getString(5));
									out.println("<td>");
									out.println("<td>");
									out.println(rset2.getDate(6));
									out.println("</td>");
									out.println("<td>");
									out.println(rset2.getDate(7));
									out.println("</td>");
									out.println("<td>");
									out.println(rset2.getString(8));
									out.println("</td>");
									out.println("<td>");
									out.println(rset2.getString(9));
									out.println("</td>");
									out.println("<td>");
									//for pictures~
									takeImageID.setInt(1,rset2.getInt(1));
									imageID = takeImageID.executeQuery();
									while(imageID.next()){
										out.println("<a href='ZoomPic.jsp?picID="+rset2.getInt(1)+"-"+imageID.getInt(1)+"' target='_blank'><img src='GetOnePic?t"+rset2.getInt(1)+"-"+imageID.getInt(1)+"'></a>");
									}
									
									out.println("</td>");
									out.println("</tr>");
								}
							dropTableName.executeQuery();
							}
							catch(SQLException e)
							{
								out.println("SQLException: " +
								e.getMessage());
								con.rollback();
							}
					out.println("</table>");
				}
				con.close();
            	}

            }
            	
          else
            {
              out.println("<br><b>Search condition is missing.</b>");
            }
        }
      %>
	</FORM>
	
	<%
		String userClass=(String)session.getAttribute("class");
		if(userClass.equals("a")){
			out.println("<FORM NAME='backForm' ACTION='AdminPage.jsp' METHOD='post' >");
		}
		else if(userClass.equals("p")){
			out.println("<FORM NAME='backForm' ACTION='PatientPage.jsp' METHOD='post' >");
		}
		else if(userClass.equals("r")){
			out.println("<FORM NAME='backForm' ACTION='RadPage.jsp' METHOD='post' >");
		}
		else if(userClass.equals("d")){
			out.println("<FORM NAME='backForm' ACTION='DoctorPage.jsp' METHOD='post' >");
		}
		out.println("<INPUT TYPE='submit' NAME='Back' VALUE='RETURN'>");
		out.println("</FORM>");
	%>
	<CENTER>User Documentation:<a href='Documentation.html' target ='_blank'><b>Documentation</b></a></CENTER>
</BODY>
</HTML>
