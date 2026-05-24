<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ include file="../common/header.jsp" %>

<h2 class="page-title">書籍一覧</h2>

<div class="card" style="margin-bottom:16px;">
    <s:form action="list" namespace="/book" method="GET" theme="simple">
        <div style="display:flex; gap:12px; flex-wrap:wrap; align-items:flex-end;">
            <div class="form-group" style="margin:0;">
                <label>タイトル</label>
                <s:textfield name="searchTitle" value="%{searchTitle}" cssStyle="width:160px;"/>
            </div>
            <div class="form-group" style="margin:0;">
                <label>著者</label>
                <s:textfield name="searchAuthor" value="%{searchAuthor}" cssStyle="width:120px;"/>
            </div>
            <div class="form-group" style="margin:0;">
                <label>カテゴリ</label>
                <s:select name="searchCategory" value="%{searchCategory}"
                          list="#{'':'すべて','NOVEL':'小説','TECH':'技術書','REFERENCE':'参考書','OTHER':'その他'}"
                          cssStyle="width:120px;"/>
            </div>
            <button type="submit" class="btn btn-primary">検索</button>
            <a href="<s:url action='list' namespace='/book'/>" class="btn btn-secondary">クリア</a>
        </div>
    </s:form>
</div>

<div class="actions">
    <c:if test="${sessionScope.loginUser != null}">
        <a href="<s:url action='create' namespace='/book'/>" class="btn btn-primary">新規登録</a>
    </c:if>
</div>

<table>
    <thead>
    <tr>
        <th>ID</th>
        <th>タイトル</th>
        <th>著者</th>
        <th>カテゴリ</th>
        <th>出版年</th>
        <th>操作</th>
    </tr>
    </thead>
    <tbody>
    <c:choose>
        <c:when test="${empty books}">
            <tr><td colspan="6" style="text-align:center;">書籍が見つかりませんでした。</td></tr>
        </c:when>
        <c:otherwise>
            <c:forEach var="book" items="${books}">
                <tr>
                    <td>${book.id}</td>
                    <td><a href="<s:url action='detail' namespace='/book'/>?id=${book.id}">${book.title}</a></td>
                    <td>${book.author}</td>
                    <td>${book.category}</td>
                    <td>${book.publishedYear}</td>
                    <td>
                        <a href="<s:url action='detail' namespace='/book'/>?id=${book.id}" class="btn btn-secondary" style="font-size:12px;">詳細</a>
                        <c:if test="${sessionScope.loginUser != null}">
                            <a href="<s:url action='edit' namespace='/book'/>?id=${book.id}" class="btn btn-warning" style="font-size:12px;">編集</a>
                            <s:form action="delete" namespace="/book" method="POST" theme="simple" style="display:inline;">
                                <s:hidden name="id" value="%{#attr.book.id}"/>
                                <button type="submit" class="btn btn-danger" style="font-size:12px;"
                                        onclick="return confirm('削除してよろしいですか？')">削除</button>
                            </s:form>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </c:otherwise>
    </c:choose>
    </tbody>
</table>

<%@ include file="../common/footer.jsp" %>
