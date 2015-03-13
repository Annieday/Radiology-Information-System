<HTML>
    <!--This page is used for test for now.-->
	<HEAD>
		<TITLE>Administrator Home Page</TITLE>
	</HEAD>
	<BODY background="BGP.jpg">
		<%@ page import="java.sql.*"%>
		<%
			if(session.getAttribute("class") != null && ((String)session.getAttribute("class")).equals("a")){
				String userName=(String)session.getAttribute("USERNAME");
				String oracleId=(String)session.getAttribute("ORACLE_ID");
    			String oraclePassword=(String)session.getAttribute("ORACLE_PASSWORD");
    	
    			Connection con = null;
	    		String driverName = "oracle.jdbc.driver.OracleDriver";
       			String dbstring = "jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";
    	
      			try{
    				Class drvClass = Class.forName(driverName);
					DriverManager.registerDriver((Driver)drvClass.newInstance());
    				con = DriverManager.getConnection(dbstring,oracleId,oraclePassword);
     				con.setAutoCommit(false);
    			}
    			catch(Exception e){
    				out.println("<p><b>Unable to Connect Oracle DB!</b></p>");
    				out.println("<p><b>Invalid UserName or Password!</b></p>");
    				out.println("<p><b>Press RETURN to the previous page.</b></p>");
        			out.println("<FORM NAME='ConnectFailForm' ACTION='Connector.html' METHOD='get'>");
        			out.println("    <CENTER><INPUT TYPE='submit' NAME='CONNECTION_FAIL' VALUE='RETURN'></CENTER>");
        			out.println("</FORM>");
    			}

      			Statement s=con.createStatement();
            	ResultSet resSet=null;
       			String sqlStatement=null;
         		
        		sqlStatement="SELECT person_id FROM users WHERE user_name='"+userName+"'";
        
        		try{
        			resSet = s.executeQuery(sqlStatement);
        		}
        		catch(Exception e){
        			out.println("<hr>" + e.getMessage() + "<hr>"); 
        		}
                Integer personId = null;
            	while(resSet != null && resSet.next()){
       				personId = (resSet.getInt("person_id"));
            	}
            
            	sqlStatement = "SELECT first_name,last_name FROM persons WHERE person_id="+personId;
            	resSet = s.executeQuery(sqlStatement);
                String first_name = null;
                String last_name=null;
            	while(resSet != null && resSet.next()){
       				first_name=resSet.getString("first_name");
       				last_name=resSet.getString("last_name");
            	}
        		out.println("<H1><CENTER><font color =Teal>Welcome! Adminstrator <a href='PersonalManage.jsp?Manage=1'><b>"+first_name+" "+last_name+"</b></a> ,You can:</font></CENTER></H1>");
        		out.println("<BR></BR>");
        		out.println("<BR></BR>");
        		out.println("<HR></HR>");
        		out.println("<H3><CENTER><font color =Maroon>User Management Module</font></CENTER></H3>");
        		//Form of update account--
        		out.println("<CENTER><font color=Teal> Enter user name to update an Account:</font></CENTER>");
        		out.println("<FORM NAME='ResetAccountForm' ACTION='ResetAccount.jsp' METHOD='post'>");
        		out.println("<CENTER><INPUT TYPE='text' NAME='UserName' VALUE=''></CENTER>");
        		out.println("<CENTER><INPUT TYPE='submit' NAME='UpdateAccount' VALUE='GO'>&nbsp;&nbsp;&nbsp;&nbsp;<a href ='AddUser.jsp?AddUser=1'><b>+ User Account</b></a></CENTER>");
        		out.println("</FORM>");
        		//Form of update person--
        		out.println("<CENTER><font color =Teal> Manage a Person: </font></CENTER>");
				out.println("<FORM NAME='ManagePersonFrom' ACTION='ManagePerson.jsp' METHOD='post'>");
				out.println("	<CENTER><SELECT NAME='ID'>");
				sqlStatement="SELECT person_id,first_name,last_name FROM persons";
				resSet=s.executeQuery(sqlStatement);
				while(resSet.next()){
					Integer person_id=resSet.getInt("person_id");
					String fname=resSet.getString("first_name");
					String lname=resSet.getString("last_name");
					out.println("<OPTION VALUE='"+person_id+"' SELECTED> "+fname+" "+lname+" ,ID: "+person_id+"</OPTION>");
				}
				out.println("</SELECT></CENTER>");
				out.println("<CENTER><INPUT TYPE='submit' NAME='ManagePerson' VALUE='GO'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href ='AddPerson.jsp?AddPerson=1'><b>+ Person</b></a></CENTER>");
				out.println("</FORM>");
        		//Form of update family doctor-----------------------------------------------------------------------------------------------
        		out.println("<CENTER><font color=Teal> Manage Family Doctor:</font></CENTER>");
        		out.println("<FORM NAME='ManageFamilyDoctorForm' ACTION='ManageFamilyDoctor.jsp' METHOD='post'>");
        		out.println("<CENTER>");
        		out.println("	<SELECT NAME='ID'>");
        		sqlStatement="SELECT DISTINCT person_id FROM users WHERE class='p'";
        		resSet=s.executeQuery(sqlStatement);
        		while(resSet.next()){
        			Integer person__id=resSet.getInt("person_id");
        			Statement subS=con.createStatement();
        			String subSqlStatement="SELECT first_name,last_name FROM persons WHERE person_id="+person__id;
        			ResultSet subResSet=subS.executeQuery(subSqlStatement);
        			while(subResSet.next()){
        				String f_name=subResSet.getString("first_name");
        				String l_name=subResSet.getString("last_name");
        				out.println("		<OPTION VALUE='"+person__id+"' SELECTED> "+f_name+" "+l_name+" ,ID: "+person__id+"</OPTION>");
        			}
        		}
        		out.println("	</SELECT>");
        		out.println("	<SELECT NAME='OPERATION'>");
        		out.println("		<OPTION VALUE='Add' SELECTED>Add</OPTION>");
        		out.println("		<OPTION VALUE='Remove' SELECTED>Remove</OPTION>");
        		out.println("	</SELECT>");
        		out.println("</CENTER>");
        		out.println("<CENTER><INPUT TYPE='submit' NAME='ManageFamilyDoctor' VALUE='GO'></CENTER>");
        		out.println("</FORM>");
        		//----------------------------------------------------------------------------------------------------------------------------
        		out.println("<HR></HR>");
                
        		out.println("<H3><CENTER><a href ='Search.jsp?SearchRequest=1'><b>Search Records</b></a></CENTER><H3>");
        		out.println("<HR></HR>");
        		
        		out.println("<H3><CENTER><a href ='Report.jsp?ReportGen=1'><b>Report Generating</b></a></CENTER><H3>");
        		out.println("<HR></HR>");
        		
        		out.println("<H3><CENTER><a href ='Analysis.jsp?AnalysisRequest=1'><b>Data Analysis</b></a></CENTER><H3>");
        		out.println("<HR></HR>");
        		
        		out.println("<FORM NAME='ReturnForm' ACTION='UserLogout.jsp' METHOD='get'>");
        		out.println("<CENTER><INPUT TYPE='submit' NAME='BACK' VALUE='Log out'></CENTER>");
        		out.println("</FORM>");
				try{
					con.close();
				}
				catch(Exception e){
					out.println("<hr>" + e.getMessage() + "<hr>");
				}
			}
			else{
				response.sendRedirect("Login.html");
			}
		%>
	<CENTER>User Documentation:<a href='Documentation.html' target ='_blank'><b>Documentation</b></a></CENTER>
	</BODY>
</HTML>
