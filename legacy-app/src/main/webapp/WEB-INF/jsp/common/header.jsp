<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>図書館管理システム</title>
    <style>
        body { font-family: sans-serif; margin: 0; background: #f5f5f5; }
        header { background: #2c3e50; color: white; padding: 12px 24px; display: flex; justify-content: space-between; align-items: center; }
        header .brand { color: #ecf0f1; text-decoration: none; font-size: 1.2em; font-weight: bold; }
        nav a { color: #bdc3c7; text-decoration: none; margin-left: 16px; }
        nav a:hover { color: white; }
        main { max-width: 960px; margin: 24px auto; padding: 0 16px; }
        .btn { display: inline-block; padding: 8px 16px; border-radius: 4px; text-decoration: none; cursor: pointer; border: none; font-size: 14px; }
        .btn-primary { background: #3498db; color: white; }
        .btn-danger { background: #e74c3c; color: white; }
        .btn-secondary { background: #95a5a6; color: white; }
        .btn-warning { background: #f39c12; color: white; }
        .btn:hover { opacity: 0.85; }
        table { width: 100%; border-collapse: collapse; background: white; }
        th, td { padding: 10px 12px; border-bottom: 1px solid #ddd; text-align: left; }
        th { background: #ecf0f1; font-weight: bold; }
        .alert-error { background: #fde8e8; border: 1px solid #e74c3c; color: #c0392b; padding: 10px 16px; border-radius: 4px; margin-bottom: 16px; }
        .card { background: white; padding: 24px; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,.1); }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; margin-bottom: 4px; font-weight: bold; }
        .form-group input, .form-group select { width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        .error-message { color: #e74c3c; font-size: 12px; margin-top: 4px; }
        .page-title { margin-bottom: 20px; }
        .actions { margin-bottom: 16px; }
        dl { display: grid; grid-template-columns: 160px 1fr; gap: 8px 16px; }
        dt { font-weight: bold; color: #555; }
        dd { margin: 0; }
    </style>
</head>
<body>
<header>
    <a class="brand" href="<s:url action='list' namespace='/book'/>">図書館管理システム</a>
    <nav>
        <a href="<s:url action='list' namespace='/book'/>">書籍一覧</a>
        <c:choose>
            <c:when test="${sessionScope.loginUser != null}">
                <a href="<s:url action='create' namespace='/book'/>">新規登録</a>
                <a href="<s:url action='logout' namespace='/auth'/>">ログアウト（${sessionScope.loginUser.displayName}）</a>
            </c:when>
            <c:otherwise>
                <a href="<s:url action='login' namespace='/auth'/>">ログイン</a>
            </c:otherwise>
        </c:choose>
    </nav>
</header>
<main>
