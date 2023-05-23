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
	
	//rank(): 중복된 등수를 허용한다. 예) 1-2-2-4-5-5-7...
	String rankSql = "SELECT first_name 이름, salary 급여, RANK() OVER(ORDER BY salary DESC) 등수 FROM employees";
	PreparedStatement rankStmt = conn.prepareStatement(rankSql);
	ResultSet rankRs = rankStmt.executeQuery();
	
	//ResultStet -> ArrayList<HashMap<String, Object>>
	ArrayList<HashMap<String, Object>> rankList = new ArrayList<HashMap<String, Object>>();
	while(rankRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("이름", rankRs.getString("이름"));
		m.put("급여", rankRs.getInt("급여"));
		m.put("등수", rankRs.getInt("등수"));
		rankList.add(m);
	}
	
	//dense_rank(): 중복된 등수를 허용하지 않는다. 예)1-2-3-4...
	String denseRankSql = "SELECT first_name 이름, salary 급여, DENSE_RANK() OVER(ORDER BY salary DESC) 등수 FROM employees";
	PreparedStatement denseRankStmt = conn.prepareStatement(denseRankSql);
	ResultSet denseRankRs = denseRankStmt.executeQuery();
	
	//ResultStet -> ArrayList<HashMap<String, Object>>
	ArrayList<HashMap<String, Object>> denseRankList = new ArrayList<HashMap<String, Object>>();
	while(denseRankRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("이름", denseRankRs.getString("이름"));
		m.put("급여", denseRankRs.getInt("급여"));
		m.put("등수", denseRankRs.getInt("등수"));
		denseRankList.add(m);
	}
	
	//row_number(): 중복된 등수롤 허용하지만 등수는 빠지는 것 없이 순서대로 진행한다. 예)1-2-2-3-4-4-5...
	String rowNumberSql = "SELECT first_name 이름, salary 급여, ROW_NUMBER() OVER(ORDER BY salary DESC) 등수 FROM employees";
	PreparedStatement rowNumberStmt = conn.prepareStatement(rowNumberSql);
	ResultSet rowNumberRs = rowNumberStmt.executeQuery();
	
	//ResultStet -> ArrayList<HashMap<String, Object>>
	ArrayList<HashMap<String, Object>> rowNumberList = new ArrayList<HashMap<String, Object>>();
	while(rowNumberRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("이름", rowNumberRs.getString("이름"));
		m.put("급여", rowNumberRs.getInt("급여"));
		m.put("등수", rowNumberRs.getInt("등수"));
		rowNumberList.add(m);
	}
	
	//ntile(n): salary 내림차순으로 정렬하고 n개의 그룹으로 나누어 어디에 속하는지 출력
	String ntileSql = "SELECT first_name 이름, salary 급여, NTILE(10) OVER(ORDER BY salary DESC) 등급 FROM employees";
	PreparedStatement ntileStmt = conn.prepareStatement(ntileSql);
	ResultSet ntileRs = ntileStmt.executeQuery();
	
	//ResultStet -> ArrayList<HashMap<String, Object>>
	ArrayList<HashMap<String, Object>> ntileList = new ArrayList<HashMap<String, Object>>();
	while(ntileRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("이름", ntileRs.getString("이름"));
		m.put("급여", ntileRs.getInt("급여"));
		m.put("등급", ntileRs.getInt("등급"));
		ntileList.add(m);
	}
%>
<!DOCTYPE html>
<html>
	<head>
	<meta charset="UTF-8">
	<title>rank ntile list</title>
	<!-- 부트스트랩5 -->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<div class="container-fluid row">
	<div class="col-3">
	<h1>rank()함수</h1>
	<p>SQL: SELECT first_name 이름, salary 급여, RANK() OVER(ORDER BY salary DESC) 등수 FROM employees;</p>
	<table class="table table-bordered">
		<tr>
			<th>이름</th>
			<th>급여</th>
			<th>등수</th>
		</tr>
		<%
			for(HashMap<String, Object> m : rankList){
		%>
				<tr>
					<td><%=(String)m.get("이름")%></td>
					<td><%=(Integer)m.get("급여")%></td>
					<td><%=(Integer)m.get("등수")%></td>
				</tr>
		<%
			}
		%>
	</table>
	</div>
	
	<div class="col-3">
	<h1>dense_rank()함수</h1>
	<p>SQL: SELECT first_name 이름, salary 급여, DENSE_RANK() OVER(ORDER BY salary DESC) 등수 FROM employees;</p>
	<table class="table table-bordered">
		<tr>
			<th>이름</th>
			<th>급여</th>
			<th>등수</th>
		</tr>
		<%
			for(HashMap<String, Object> m : denseRankList){
		%>
				<tr>
					<td><%=(String)m.get("이름")%></td>
					<td><%=(Integer)m.get("급여")%></td>
					<td><%=(Integer)m.get("등수")%></td>
				</tr>
		<%
			}
		%>
	</table>
	</div>
	
	<div class="col-3">
	<h1>row_number()함수</h1>
	<p>SQL: SELECT first_name 이름, salary 급여, ROW_NUMBER() OVER(ORDER BY salary DESC) 등수 FROM employees;</p>
	<table class="table table-bordered">
		<tr>
			<th>이름</th>
			<th>급여</th>
			<th>등수</th>
		</tr>
		<%
			for(HashMap<String, Object> m : rowNumberList){
		%>
				<tr>
					<td><%=(String)m.get("이름")%></td>
					<td><%=(Integer)m.get("급여")%></td>
					<td><%=(Integer)m.get("등수")%></td>
				</tr>
		<%
			}
		%>
	</table>
	</div>
	
	<div class="col-3">
	<h1>ntile()함수</h1>
	<p>SQL: SELECT first_name 이름, salary 급여, NTILE() OVER(ORDER BY salary DESC) 등수 FROM employees;</p>
	<table class="table table-bordered">
		<tr>
			<th>이름</th>
			<th>급여</th>
			<th>등급</th>
		</tr>
		<%
			for(HashMap<String, Object> m : ntileList){
		%>
				<tr>
					<td><%=(String)m.get("이름")%></td>
					<td><%=(Integer)m.get("급여")%></td>
					<td><%=(Integer)m.get("등급")%></td>
				</tr>
		<%
			}
		%>
	</table>
	</div>
</div>
</body>
</html>