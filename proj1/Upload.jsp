<HTML>
<HEAD>
<TITLE>Upload Input Page</TITLE>
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
		String userName=null;
		if(request.getParameter("UploadRecord") != null && ((String)session.getAttribute("class"))!=null){
			userName = (String)session.getAttribute("USERNAME");
		}
		else{
			response.sendRedirect("Login.html");
		}
     %>
	<H1>
		<CENTER>
			<font color=Teal>Please Enter the information needs to be
				upload: </font>
		</CENTER>
	</H1>
	<BR></BR>
	<BR></BR>
	<FORM NAME="upload_record_form" ACTION="Upload_Processor.jsp"
		METHOD="post">
		<TABLE style="margin: 0px auto">
			<TR>
				<TD><B><I><font color=Maroon>Choose Patient: </font></I></B></TD>
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
							out.println("<OPTION VALUE='"+id+"' SELECTED> "+fname+" "+lname+" ID: "+id+" </OPTION>");
						}
					%>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD><B><I><font color=Maroon>Choose Doctor: </font></I></B></TD>
				<TD>
					<SELECT NAME='doctorID'>
					<%
						sql="SELECT * FROM persons p WHERE p.person_id=ANY(SELECT u.person_id FROM users u WHERE u.class='d')";
						resSet=s.executeQuery(sql);
						while(resSet.next()){
							Integer id=resSet.getInt("person_id");
							String fname=resSet.getString("first_name");
							String lname=resSet.getString("last_name");
							out.println("<OPTION VALUE='"+id+"' SELECTED> "+fname+" "+lname+" ID: "+id+" </OPTION>");
						}
						con.close();
					%>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD><B><I><font color=Maroon>Test type: </font></I></B></TD>
				<TD><INPUT TYPE="text" NAME="testType" VALUE=""></TD>
			</TR>
			<TR>
				<TD><B><I><font color=Maroon>Prescribing date
								(MM-DD-YYYY): </font></I></B></TD>
				<TD><p>
						Date: <INPUT TYPE="text" class="datepicker" NAME="pDate" VALUE="" />
					</p></TD>
			</TR>
			<TR>
				<TD><B><I><font color=Maroon>Test date
								(MM-DD-YYYY): </font></I></B></TD>
				<TD><p>
						Date: <INPUT TYPE="text" class="datepicker" NAME="tDate" VALUE="" />
					</p></TD>
			</TR>
			<TR>
				<TD><B><I><font color=Maroon>Diagnosis: </font></I></B></TD>
				<TD><INPUT TYPE="text" NAME="diagnosis" VALUE=""></TD>
			</TR>
			<TR>
				<TD><B><I><font color=Maroon>Description: </font></I></B></TD>
				<TD><INPUT TYPE="text" NAME="description" VALUE=""></TD>
			</TR>
		</TABLE>
		<CENTER>
			<INPUT TYPE="submit" NAME="CommitUploadRecord" VALUE="UPLOAD">
		</CENTER>
	</FORM>
		<FORM NAME='ReturnForm' ACTION='RadPage.jsp' METHOD='get'>
		<CENTER><INPUT TYPE='submit' NAME='return' VALUE='RETURN'></CENTER>
		</FORM>
		<CENTER>User Documentation:<a href='Documentation.html' target ='_blank'><b>Documentation</b></a></CENTER>
</BODY>
</HTML>
