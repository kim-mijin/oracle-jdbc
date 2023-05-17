<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	// OracleDB에 접속
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dbUrl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbUser = "hr";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println(conn + " <--group_by_function conn : 접속성공");
	
	/*
		group by절에서만 가능한 확장함수
		1. groupsets()
		2. rollup()
		3. cube()
	*/
	
	// grouping sets() 
	String groupSql = "";
	PreparedStatement groupStmt = null;
	ResultSet groupRs = null;
	
	groupSql = "SELECT department_Id 부서ID, job_id 직무ID, COUNT(*) 부서인원 from employees GROUP BY GROUPING SETS(department_id, job_id)";
	groupStmt = conn.prepareStatement(groupSql);
	groupRs = groupStmt.executeQuery();
	
	// ResultSet -> ArrayList
	ArrayList<HashMap<String, Object>> groupList = new ArrayList<HashMap<String, Object>>();
	while(groupRs.next()){
		HashMap<String, Object> g = new HashMap<String, Object>();
		g.put("부서ID", groupRs.getInt("부서ID"));
		g.put("직무ID", groupRs.getString("직무ID"));
		g.put("부서인원", groupRs.getInt("부서인원"));
		groupList.add(g);
	}
	System.out.println(groupList.size() + " <--group_by_function groupList.size()");
	
	// rollup()
	String rollSql = "";
	PreparedStatement rollStmt = null;
	ResultSet rollRs = null;
	
	rollSql = "SELECT department_Id 부서ID, job_id 직무ID, COUNT(*) 부서인원 from employees GROUP BY ROLLUP(department_id, job_id)";
	rollStmt = conn.prepareStatement(rollSql);
	rollRs = rollStmt.executeQuery();
	
	// ResultSet -> ArrayList
	ArrayList<HashMap<String, Object>> rollList = new ArrayList<HashMap<String, Object>>();
	while(rollRs.next()){
		HashMap<String, Object> r = new HashMap<String, Object>();
		r.put("부서ID", rollRs.getInt("부서ID"));
		r.put("직무ID", rollRs.getString("직무ID"));
		r.put("부서인원", rollRs.getInt("부서인원"));
		rollList.add(r);
	}
	System.out.println(rollList.size() + " <--group_by_function rollList.size()");
	
	// cube()
	String cubeSql = "";
	PreparedStatement cubeStmt = null;
	ResultSet cubeRs = null;
	
	cubeSql = "SELECT department_Id 부서ID, job_id 직무ID, COUNT(*) 부서인원 from employees GROUP BY CUBE(department_id, job_id)";
	cubeStmt = conn.prepareStatement(cubeSql);
	cubeRs = cubeStmt.executeQuery();
	
	// ResultSet -> ArrayList
	ArrayList<HashMap<String, Object>> cubeList = new ArrayList<HashMap<String, Object>>();
	while(cubeRs.next()){
		HashMap<String, Object> c = new HashMap<String, Object>();
		c.put("부서ID", cubeRs.getInt("부서ID"));
		c.put("직무ID", cubeRs.getString("직무ID"));
		c.put("부서인원", cubeRs.getInt("부서인원"));
		cubeList.add(c);
	}
	System.out.println(cubeList.size() + " <--group_by_function cubeList.size()");
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>GROUP BY FUNCTION</title>
	<style>
		table, td {
			border: 1px solid #000000;
			border-collapse: collapse;
		}
	</style>
</head>
<body>
	<h1>group by절 확장함수</h1>
		<h2>GROUPSETS()</h2>
		<p>SELECT department_Id 부서ID, job_id 직무ID, COUNT(*) 부서인원 from employees GROUP BY GROUPING SETS(department_id, job_id);</p>
		<table>
			<tr>
				<th>부서ID</th>
				<th>직무ID</th>
				<th>부서인원</th>
			</tr>
			<%
				for(HashMap<String,Object> g : groupList){	
			%>
					<tr>
						<td><%=g.get("부서ID")%></td>
						<td><%=g.get("직무ID")%></td>
						<td><%=g.get("부서인원")%></td>
					</tr>
			<%
				}
			%>
			</table>

			<h2>ROLLUP()</h2>
			<p>SELECT department_Id 부서ID, job_id 직무ID, COUNT(*) 부서인원 from employees GROUP BY ROLLUP(department_id, job_id);</p>
			<table>
				<tr>
					<th>부서ID</th>
					<th>직무ID</th>
					<th>부서인원</th>
				</tr>
			<%
				for(HashMap<String,Object> r : rollList){	
			%>
					<tr>
						<td><%=r.get("부서ID")%></td>
						<td><%=r.get("직무ID")%></td>
						<td><%=r.get("부서인원")%></td>
					</tr>
			<%
				}
			%>
			</table>

			<h2>CUBE()</h2>
			<p>SELECT department_Id 부서ID, job_id 직무ID, COUNT(*) 부서인원 from employees GROUP BY CUBE(department_id, job_id);</p>
			<table>
			<tr>
				<th>부서ID</th>
				<th>직무ID</th>
				<th>부서인원</th>
			</tr>
			<%
				for(HashMap<String,Object> c : cubeList){	
			%>
					<tr>
						<td><%=c.get("부서ID")%></td>
						<td><%=c.get("직무ID")%></td>
						<td><%=c.get("부서인원")%></td>
					</tr>
			<%
				}
			%>
		</table>
</body>
</html>