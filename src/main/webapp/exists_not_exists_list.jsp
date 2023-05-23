<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	//DB접속
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dbUrl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbUser = "hr";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println(conn);
	
	//exists: department_id의 값이 department테이블에 존재하는 department_id인 경우에만 출력 
	String existsSql = "SELECT e.employee_id 사원번호, e.first_name 이름, e.department_id 부서번호 FROM employees e "
						+ "WHERE EXISTS (SELECT * FROM departments d WHERE d.department_id = e.department_id)";
	PreparedStatement existsStmt = conn.prepareStatement(existsSql);
	ResultSet existsRs = existsStmt.executeQuery();
	
	//ResultStet -> ArrayList<HashMap<String, Object>>
	ArrayList<HashMap<String, Object>> existsList = new ArrayList<HashMap<String, Object>>();
	while(existsRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("사원번호", existsRs.getInt("사원번호"));
		m.put("이름", existsRs.getString("이름"));
		m.put("부서번호", existsRs.getInt("부서번호"));
		existsList.add(m);
	}
	
	//exists: department_id의 값이 department테이블에 존재하지 않는 department_id인 경우에만 출력 
	String notExistsSql = "SELECT e.employee_id 사원번호, e.first_name 이름, e.department_id 부서번호 FROM employees e "
						+ "WHERE NOT EXISTS (SELECT * FROM departments d WHERE d.department_id = e.department_id)";
	PreparedStatement notExistsStmt = conn.prepareStatement(notExistsSql);
	ResultSet notExistsRs = notExistsStmt.executeQuery();
	
	//ResultStet -> ArrayList<HashMap<String, Object>>
	ArrayList<HashMap<String, Object>> notExistsList = new ArrayList<HashMap<String, Object>>();
	while(notExistsRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("사원번호", notExistsRs.getInt("사원번호"));
		m.put("이름", notExistsRs.getString("이름"));
		m.put("부서번호", notExistsRs.getInt("부서번호"));
		notExistsList.add(m);
	}
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>exists not exists list</title>
	<!-- 부트스트랩5 -->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>	
</head>
<body>
<div class="container row">
	<div class="col-6">
	<h1>exists</h1>
	<p>SQL: SELECT e.employee_id 사원번호, e.first_name 이름, e.department_id 부서번호<br>
		FROM employees e <br>
		WHERE EXISTS (SELECT * FROM departments d WHERE d.department_id = e.department_id);</p>
	<table class="table table-bordered">
		<tr>
			<th>사원번호</th>
			<th>이름</th>
			<th>부서번호</th>
		</tr>
		<%
			for(HashMap<String, Object> m : existsList){
		%>
				<tr>
					<td><%=(Integer)m.get("사원번호")%></td>
					<td><%=(String)m.get("이름")%></td>
					<td><%=(Integer)m.get("부서번호")%></td>
				</tr>
		<%
			}
		%>
	</table>
	</div>

	<div class="col-6">
	<h1>not exists</h1>
	<p>SQL: SELECT e.employee_id 사원번호, e.first_name 이름, e.department_id 부서번호<br>
		FROM employees e <br>
		WHERE NOT EXISTS (SELECT * FROM departments d WHERE d.department_id = e.department_id);</p>
	<table class="table table-bordered">
		<tr>
			<th>사원번호</th>
			<th>이름</th>
			<th>부서번호</th>
		</tr>
		<%
			for(HashMap<String, Object> m : notExistsList){
		%>
				<tr>
					<td><%=(Integer)m.get("사원번호")%></td>
					<td><%=(String)m.get("이름")%></td>
					<td><%=(Integer)m.get("부서번호")%></td>
				</tr>
		<%
			}
		%>
	</table>
	</div>
</div>
</body>
</html>