<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<template:addResources type="javascript" resources="jquery.min.js,jquery-ui.min.js,jquery.jeditable.js"/>
<template:addResources type="javascript" resources="jquery.fancybox.js"/>
<template:addResources type="css" resources="jquery.fancybox.css"/>

<c:set var="pageNode" value="${jcr:getParentOfType(currentNode, 'jnt:page')}"/>
<c:if test="${empty pageNode}">
    <c:choose>
        <c:when test="${jcr:isNodeType(renderContext.mainResource.node, 'jnt:page')}">
            <c:set var="pageNode" value="${renderContext.mainResource.node}"/>
        </c:when>
        <c:otherwise>
            <c:set var="pageNode" value="${jcr:getParentOfType(renderContext.mainResource.node, 'jnt:page')}"/>
        </c:otherwise>
    </c:choose>
</c:if>
<c:set var="canDelete" value="${jcr:hasPermission(renderContext.mainResource.node,'deleteBlog')}"/>
<c:set var="canEdit" value="${jcr:hasPermission(renderContext.mainResource.node,'editBlog')}"/>

<c:if test="${canDelete}">
<template:tokenizedForm>
    <form action="<c:url value='${url.base}${renderContext.mainResource.node.path}'/>" method="post" id="jahia-blog-delete-${currentNode.UUID}">
        <input type="hidden" name="jcrRedirectTo" value="<c:url value='${url.base}${jcr:findDisplayableNode(renderContext.mainResource.node.parent, renderContext).path}'/>"/>
            <%-- Define the output format for the newly created node by default html or by jcrRedirectTo--%>
        <input type="hidden" name="jcrNewNodeOutputFormat" value="html"/>
        <input type="hidden" name="jcrMethodToCall" value="delete"/>
    </form>
</template:tokenizedForm>
</c:if>
<c:if test="${not empty pageNode}">
    <div>
    <h2 class="pageTitle"><c:out value="${pageNode.displayableName}" /><c:if
            test="${not jcr:isNodeType(renderContext.mainResource.node, 'jnt:page')}">
        ><c:out value="${functions:abbreviate(renderContext.mainResource.node.displayableName,15,30,'...')}" /></c:if></h2>
    <c:if test="${canEdit or canDelete}">
        <span class="pageedit">
            <c:if test="${canDelete}">
            	 <c:set var="delmessparamvalue">
            	    <c:out value="${renderContext.mainResource.node.properties['jcr:title'].string}" />
            	 </c:set>
            <a class="pagedelete" id="linkPageDelete" href="#" onclick="confirm('<fmt:message key="label.blogpage.delete.warning"><fmt:param value="${delmessparamvalue}"/></fmt:message>')?document.getElementById('jahia-blog-delete-${currentNode.UUID}').submit():false;"><fmt:message key="label.blogpage.delete"/></a>
            </c:if><c:if test="${canEdit}">
            <a class="pageedit" id="linkPageEdit" href="#formPageEdit"><fmt:message key="label.blogpage.edit"/></a>
            </c:if>
        </span>
        <c:if test="${canEdit}">
        <template:addResources type="inlinejavascript">
            <script>
                $(document).ready(function() {
                    $("#linkPageEdit").fancybox({
                        'autoDimensions'	: false,
                        'width'         	: 450,
                        'height'        	: 350,
                        'scrolling'          : 'no',
                        'titleShow'          : false,
                        'showCloseButton'    : true,
                        'transitionIn'       : 'none',
                        'transitionOut'      : 'none',
                        'centerOnScroll'     : true
                    })
                });
            </script>
        </template:addResources>
        <div style="display:none">
            <template:tokenizedForm>
            <form id="formPageEdit" method="post" action="${pageNode.name}/" name="blogPage">
            <input type="hidden" name="jcrAutoCheckin" value="true">
            <input type="hidden" name="jcrNodeType" value="jnt:page">
                <p>
                    <label for="title"><fmt:message key="title"/>: </label>
                    <c:set var="pageTitleString" value='${pageNode.properties["jcr:title"].string}'/>
                    <input id="title" type="text" value="<c:out value='${pageTitleString}'/>" name="jcr:title"/>
                </p>
                <p>
                    <label for="description"><fmt:message key="label.description"/>: </label>
                    <textarea id="description" rows="10" cols="73" name="jcr:description"><c:out value='${pageNode.properties["jcr:description"].string}'/></textarea>
                </p>
                <p>
                    <input
                            class="button"
                            type="button"
                            tabindex="16"
                            value="<fmt:message key='blog.label.save'/>"
                            onclick="document.blogPage.submit();"
                            />
                </p>
            </form>
            </template:tokenizedForm>
        </div>
        </c:if>
    </c:if>
    </div>

</c:if>
