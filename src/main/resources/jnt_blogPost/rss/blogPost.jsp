<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jcr:nodeProperty node="${currentNode}" name="jcr:title" var="title"/>
<jcr:nodeProperty node="${currentNode}" name="jcr:created" var="created"/>
<jcr:nodeProperty node="${currentNode}" name="text" var="text"/>
<item>
    <title>${fn:escapeXml(title.string)}</title>
    <link><c:url value="${url.server}${url.context}${url.base}${currentNode.path}.html" var="itemUrl"/>${fn:escapeXml(itemUrl)}</link>
    <guid>${fn:escapeXml(itemUrl)}</guid>
    <description>${functions:abbreviate(functions:removeHtmlTags(text.string),200,250,'...')}</description>
    <pubDate><fmt:formatDate value="${created.date.time}" pattern="EEE, dd MMM yyyy HH:mm:ss Z"/></pubDate>
</item>