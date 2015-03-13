<HTML>
<HEAD>
<TITLE>Analysis Input Page</TITLE>
<!--Adapted from http://javarevisited.blogspot.ca/2013/10/how-to-use-multiple-jquery-ui-date.html-->
<link rel="stylesheet"
	href="//code.jquery.com/ui/1.10.4/themes/smoothness/jquery-ui.css">
<script src="//code.jquery.com/jquery-1.9.1.js"></script>
<script src="//code.jquery.com/ui/1.10.4/jquery-ui.js"></script>
<link rel="stylesheet" href="/resources/demos/style.css">
<style>
.datepicker {
	
}
</style>
<script>
	$(function() {
		$(".datepicker").datepicker({
			changeMonth : true,
			changeYear : true
		});
	});
</script>
</HEAD>
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
	<%
		if(request.getParameter("AnalysisRequest") != null){
			
		}
		else{
			response.sendRedirect("Login.html");
		}
	%>
	<H1>
		<CENTER>
			<font color=Teal>Please Enter the information to search the database for analysis: </font>
		</CENTER>
	</H1>
	
	<FORM NAME="ConfrimAnalysis" ACTION="ConfrimAnalysis.jsp"
		METHOD="post">
		<TABLE style="margin: 0px auto">
			<TR>
				<TD><B><I><font color=Maroon>Select a patient: </font></I></B></TD>
				<TD>
					<SELECT NAME='patientID'>
					<%
						Connection con=getConnection((String)session.getAttribute("ORACLE_ID"),(String)session.getAttribute("ORACLE_PASSWORD"));
						Statement s=con.createStatement();
						String sql="SELECT * FROM persons p WHERE p.person_id=ANY(SELECT u.person_id FROM users u WHERE u.class='p')";
						ResultSet resSet=s.executeQuery(sql);
						while(resSet.next()){
							Integer id=resSet.getInt("person_id");
							String fname=resSet.getString("first_name");
							String lname=resSet.getString("last_name");
							out.println("<OPTION VALUE='"+id+"' SELECTED> "+fname+" "+lname+" ,ID: "+id+" </OPTION>");
						}
						con.close();
					%>
					<OPTION VALUE="" SELECTED> Null </OPTION>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD></TD>
				<TD>
					<input type="checkbox" name="GroupByPatient" value="True"><B><I><font color=Teal>Group by this attribute.</font></I></B>
				</TD>
			</TR>
			<TR>
				<TD><B><I><font color=Maroon>Test Type: </font></I></B></TD>
				<TD><INPUT TYPE="text" NAME="testType" VALUE=""></TD>
			</TR>
			<TR>
				<TD></TD>
				<TD>
					<input type="checkbox" name="GroupByTestType" value="True"><B><I><font color=Teal>Group by this attribute.</font></I></B>
				</TD>
			</TR>
			<TR>
				<TD><B><I><font color=Maroon>From (MM-DD-YYYY): </font></I></B></TD>
				<TD><INPUT TYPE="text" CLASS="datepicker" NAME="fDate" VALUE=""></TD>
			</TR>
			<TR>
				<TD><B><I><font color=Maroon>To (MM-DD-YYYY): </font></I></B></TD>
				<TD><INPUT TYPE="text" CLASS="datepicker" NAME="tDate" VALUE=""></TD>
			</TR>
			<TR>
				<TD><B><I><font color=Maroon>Group by range:</font></I></B></TD>
				<TD>
					<SELECT NAME='groupByRange'>
						<OPTION VALUE='week' SELECTED> Week </OPTION>
						<OPTION VALUE='month' SELECTED> Month </OPTION>
						<OPTION VALUE='year' SELECTED> Year </OPTION>
						<OPTION VALUE="" SELECTED> Null </OPTION>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD>
					<CENTER><INPUT TYPE='submit' NAME='StartAnalysis' VALUE='Go!'></CENTER>
				</TD>
			</TR>
		</TABLE>
	</FORM>
	<FORM NAME='ReturnForm' ACTION='AdminPage.jsp' METHOD='get'>
	<CENTER><INPUT TYPE='submit' NAME='return' VALUE='RETURN'></CENTER>
	</FORM>"
	<CENTER>User Documentation:<a href='Documentation.html' target ='_blank'><b>Documentation</b></a></CENTER>
</BODY>
</HTML>
