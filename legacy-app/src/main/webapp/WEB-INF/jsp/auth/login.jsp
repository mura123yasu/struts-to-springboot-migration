<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>ログイン - 図書館管理システム</title>
    <style>
        body { font-family: sans-serif; background: #f5f5f5; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .login-card { background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,.15); width: 320px; }
        h2 { margin: 0 0 24px; text-align: center; color: #2c3e50; }
        .form-group { margin-bottom: 16px; }
        label { display: block; margin-bottom: 4px; font-weight: bold; }
        input { width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        .btn { width: 100%; padding: 10px; background: #3498db; color: white; border: none; border-radius: 4px; font-size: 16px; cursor: pointer; }
        .btn:hover { background: #2980b9; }
        .alert-error { background: #fde8e8; border: 1px solid #e74c3c; color: #c0392b; padding: 10px 16px; border-radius: 4px; margin-bottom: 16px; font-size: 14px; }
    </style>
</head>
<body>
<div class="login-card">
    <h2>図書館管理システム</h2>
    <s:actionerror cssClass="alert-error" theme="simple"/>
    <s:form action="login" namespace="/auth" method="POST" theme="simple">
        <div class="form-group">
            <label>ユーザー名</label>
            <s:textfield name="username" value="%{username}"/>
        </div>
        <div class="form-group">
            <label>パスワード</label>
            <s:password name="password"/>
        </div>
        <button type="submit" class="btn">ログイン</button>
    </s:form>
</div>
</body>
</html>
