<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	//OracleDB에 접속
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dbUrl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbUser = "gdj66";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	System.out.println(conn + " <--null_function conn : 접속성공");
	
	// nvl
	String nvlSql = "";
	PreparedStatement nvlStmt = null;
	ResultSet nvlRs = null;
	
	nvlSql = "SELECT 이름, nvl(일분기, 0) 실적 from 실적"; // quarter1값이 null이 아니면 quarter1, null이면 0을 반환
	nvlStmt = conn.prepareStatement(nvlSql);
	nvlRs = nvlStmt.executeQuery();
	
	// ResultSet -> ArrayList
	ArrayList<HashMap<String, Object>> nvlList = new ArrayList<HashMap<String, Object>>();
	while(nvlRs.next()){
		HashMap<String, Object> n = new HashMap<String, Object>();
		n.put("이름", nvlRs.getString("이름"));
		n.put("실적", nvlRs.getInt("실적"));
		nvlList.add(n);
	}
	System.out.println(nvlList.size() + " <--null_function nvlList.size()");
	
	// nvl2
	String nvl2Sql = "";
	PreparedStatement nvl2Stmt = null;
	ResultSet nvl2Rs = null;
	
	nvl2Sql = "SELECT 이름, nvl2(일분기, 'success', 'fail') 실적 from 실적"; // quarter1값이 null이 아니면 success, null이면 fail 반환
	nvl2Stmt = conn.prepareStatement(nvl2Sql);
	nvl2Rs = nvl2Stmt.executeQuery();
	
	// ResultSet -> ArrayList
	ArrayList<HashMap<String, Object>> nvl2List = new ArrayList<HashMap<String, Object>>();
	while(nvl2Rs.next()){
		HashMap<String, Object> n = new HashMap<String, Object>();
		n.put("이름", nvl2Rs.getString("이름"));
		n.put("실적", nvl2Rs.getString("실적")); //performance열의 값은 nvl2함수적용으로 숫자가 아닌 문자열이 출력 된다 -> getString
		nvl2List.add(n);
	}
	System.out.println(nvl2List.size() + " <--null_function nvl2List.size()");
	
	// nullif
	String nullIfSql = "";
	PreparedStatement nullIfStmt = null;
	ResultSet nullIfRs = null;
	
	nullIfSql = "SELECT 이름, nullif(사분기, 100) 실적 from 실적"; //quarter4가 100이면 null반환 
	nullIfStmt = conn.prepareStatement(nullIfSql);
	nullIfRs = nullIfStmt.executeQuery();
	
	// ResultSet -> ArrayList
	ArrayList<HashMap<String, Object>> nullIfList = new ArrayList<HashMap<String, Object>>();
	while(nullIfRs.next()){
		HashMap<String, Object> n = new HashMap<String, Object>();
		n.put("이름", nullIfRs.getString("이름"));
		n.put("실적", nullIfRs.getInt("실적"));
		nullIfList.add(n);
	}
	System.out.println(nullIfList.size() + " <--null_function nullIfList.size()");
	
	// coalesce
	String coalSql = "";
	PreparedStatement coalStmt = null;
	ResultSet coalRs = null;
	
	coalSql = "SELECT 이름, coalesce(일분기, 이분기, 삼분기, 사분기) 실적 from 실적"; // quarter1~4중 null이 아닌 첫번쨰 값 반환
	coalStmt = conn.prepareStatement(coalSql);
	coalRs = coalStmt.executeQuery();
	
	// ResultSet -> ArrayList
	ArrayList<HashMap<String, Object>> coalList = new ArrayList<HashMap<String, Object>>();
	while(coalRs.next()){
		HashMap<String, Object> n = new HashMap<String, Object>();
		n.put("이름", coalRs.getString("이름"));
		n.put("실적", coalRs.getInt("실적"));
		coalList.add(n);
	}
	System.out.println(coalList.size() + " <--null_function coalList.size()");
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>NULL FUNCTION</title>
	<style>
		table, td {
			border: 1px solid #000000;
			border-collapse: collapse;
		}
	</style>
</head>
<body>
	<h1>Null Function</h1>
	<h2>nvl()</h2>
	<p>select 이름, nvl(일분기, 0) from 실적;</p>
	<table>
	<%
		for(HashMap<String, Object> n : nvlList){
	%>
			<tr>
				<td><%=n.get("이름")%></td>
				<td><%=n.get("실적")%></td>
			</tr>
	<%
		}
	%>
	</table>
	
	<h2>nvl2()</h2>
	<p>select 이름, nvl2(일분기, 'success', 'fail') from 실적;</p>
	<table>
	<%
		for(HashMap<String, Object> n : nvl2List){
	%>
			<tr>
				<td><%=n.get("이름")%></td>
				<td><%=n.get("실적")%></td>
			</tr>
	<%
		}
	%>
	</table>
	
		<h2>nullif()</h2>
		<p>select 이름, nullif(사분기, 100) from 실적;</p>
	<table>
	<%
		for(HashMap<String, Object> n : nullIfList){
	%>
			<tr>
				<td><%=n.get("이름")%></td>
				<td><%=n.get("실적")%></td>
			</tr>
	<%
		}
	%>
	</table>
	
		<h2>coalesce()</h2>
		<p>select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) from 실적;</p>
	<table>
	<%
		for(HashMap<String, Object> c : coalList){
	%>
			<tr>
				<td><%=c.get("이름")%></td>
				<td><%=c.get("실적")%></td>
			</tr>
	<%
		}
	%>
	</table>
</body>
</html>