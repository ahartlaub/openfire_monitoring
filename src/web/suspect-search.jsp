<%@ page errorPage="/error.jsp" import="org.jivesoftware.openfire.plugin.MonitoringPlugin"%>
<%@ page import="org.jivesoftware.openfire.archive.ArchiveSearch" %>
<%@ page import="org.jivesoftware.openfire.archive.ArchiveSearcher" %>
<%@ page import="org.jivesoftware.openfire.archive.Conversation" %>
<%@ page import="org.jivesoftware.openfire.archive.ConversationManager" %>
<%@ page import="org.jivesoftware.openfire.XMPPServer" %>
<%@ page import="org.jivesoftware.openfire.user.UserManager" %>
<%@ page import="org.jivesoftware.openfire.user.UserNameManager" %>
<%@ page import="org.jivesoftware.openfire.user.UserNotFoundException" %>
<%@ page import="org.jivesoftware.util.*" %>
<%@ page import="org.xmpp.packet.JID" %>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>

<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/fmt_rt" prefix="fmt" %>
<%
    // Get handle on the Monitoring plugin
    MonitoringPlugin plugin = (MonitoringPlugin) XMPPServer.getInstance().getPluginManager().getPlugin(
            "monitoring");
    ArchiveSearcher archiveSearcher = (ArchiveSearcher) plugin.getModule(
            ArchiveSearcher.class);

    ConversationManager conversationManager = (ConversationManager) plugin.getModule(
            ConversationManager.class);


    boolean submit = request.getParameter("submitForm") != null;
    if (!submit) {
        submit = request.getParameter("parseRange") != null;
    }

    Collection<Conversation> conversations = null;
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");
    String txtMessageCount = request.getParameter("txtMessageCount");
    String txtMaxTime = request.getParameter("txtMaxTime");
    Date parsedStartDate = null;
    Date parsedEndDate = null;
    long messageCount = 0;
    long maxTime = 0;
    String anyText = LocaleUtils.getLocalizedString("suspect.settings.any", "monitoring");

    int start = 0;
    int range = 15;
    int numPages = 1;
    int curPage = (start / range) + 1;

    if (anyText.equals(startDate)) {
        startDate = null;
    }

    if (anyText.equals(endDate)) {
        endDate = null;
    }

    if(txtMessageCount == null)
    {
        txtMessageCount = "None";
    }

    if(txtMaxTime == null)
    {
        txtMaxTime = "None";
    }

    if (startDate != null && startDate.length() > 0) {
     DateFormat formatter = new SimpleDateFormat("MM/dd/yy");
     try {
         Date date = formatter.parse(startDate);
         parsedStartDate = date;
     }
     catch (Exception e) {
         // TODO: mark as an error in the JSP instead of logging..
         Log.error(e);
     }
    }

    if (endDate != null && endDate.length() > 0) {
     DateFormat formatter = new SimpleDateFormat("MM/dd/yy");
     try {
         Date date = formatter.parse(endDate);
         date = new Date(date.getTime() + JiveConstants.DAY - 1);
         parsedEndDate = date;
     }
     catch (Exception e) {
         // TODO: mark as an error in the JSP instead of logging..
         Log.error(e);
     }
    }

    if (txtMessageCount != null && txtMessageCount.length() > 0)
    {
        try
        {
           messageCount = Long.valueOf(txtMessageCount).longValue();
        }
        catch (Exception ex)
        {
          Log.error(ex);
        }
    }

    if (txtMaxTime != null && txtMaxTime.length() > 0)
    {
        try
        {
           maxTime = Long.valueOf(txtMaxTime).longValue();
           maxTime = (maxTime * 60 * 1000);
        }
        catch (Exception ex)
        {
          Log.error(ex);
        }
    }
    if (submit) {
    UserManager userManager = UserManager.getInstance();
    ArchiveSearch search = new ArchiveSearch();
    JID participant1JID = null;
    JID participant2JID = null;

    String serverName = XMPPServer.getInstance().getServerInfo().getXMPPDomain();

    start = ParamUtils.getIntParameter(request, "start", 0);
    range = 15;


    conversations = archiveSearcher.searchDatabaseForSuspects(parsedStartDate,parsedEndDate,messageCount,maxTime);

    numPages = (int) Math.ceil((double) conversations.size() / (double) range);
    curPage = (start / range) + 1;
    }
    boolean isArchiveEnabled = conversationManager.isArchivingEnabled();
%>

<html>
<head>
<title><fmt:message key="suspect.search.title" /> - 1.0.3</title>
<meta name="pageID" content="suspect-search"/>
<script src="/js/prototype.js" type="text/javascript"></script>
<script src="/js/scriptaculous.js" type="text/javascript"></script>
<script src="dwr/engine.js" type="text/javascript"></script>
<script src="dwr/util.js" type="text/javascript"></script>
<script src="dwr/interface/conversations.js" type="text/javascript"></script>
<script type="text/javascript" language="javascript" src="scripts/tooltips/domLib.js"></script>
<script type="text/javascript" language="javascript" src="scripts/tooltips/domTT.js"></script>

<style type="text/css">@import url( /js/jscalendar/calendar-win2k-cold-1.css );</style>
<script type="text/javascript" src="/js/jscalendar/calendar.js"></script>
<script type="text/javascript" src="/js/jscalendar/i18n.jsp"></script>
<script type="text/javascript" src="/js/jscalendar/calendar-setup.js"></script>

<script type="text/javascript">
    function hover(oRow) {
        oRow.style.background = "#A6CAF0";
        oRow.style.cursor = "pointer";
    }

    function noHover(oRow) {
        oRow.style.background = "white";
    }

    function viewConversation(conversationID) {
        window.frames['view'].location.href = "conversation-viewer.jsp?conversationID=" + conversationID;
    }

    function submitFormAgain(start, range){
        document.f.start.value = start;
        document.f.range.value = range;
        document.f.parseRange.value = "true";
        document.f.submit();
    }
</script>
<style type="text/css">
    .small-label {
        font-size: 11px;
        font-weight: bold;
        font-family: Verdana, Arial, sans-serif;
    }

    .small-label-no-bold {
        font-size: 11px;
        font-family: Verdana, Arial, sans-serif;
    }


    .small-label-with-padding {
        font-size: 12px;
        font-weight: bold;
        font-family: Verdana, Arial, sans-serif;
    }


    .small-text {
        font-size: 11px;
        font-family: Verdana, Arial, sans-serif;
        line-height: 11px;
    }

    .very-small-label {
        font-size: 10px;
        font-weight: bold;
        font-family: Verdana, Arial, sans-serif;
        padding-right:5px;
    }


    .stat {
        margin: 0px 0px 8px 0px;
        border: 1px solid #cccccc;
        -moz-border-radius: 3px;
    }

    .stat td table {
        margin: 5px 10px 5px 10px;
    }
    .stat div.verticalrule {
        display: block;
        width: 1px;
        height: 110px;
        background-color: #cccccc;
        overflow: hidden;
        margin-left: 3px;
        margin-right: 3px;
    }

    .conversation-body {
        color: black;
        font-size: 11px;
        font-family: Verdana, Arial, sans-serif;
    }

    .conversation-label1 {
        color: blue;
        font-size: 10px;
        font-family: Verdana, Arial, sans-serif;
    }

    .conversation-label2 {
        color: red;
        font-size: 10px;
        font-family: Verdana, Arial, sans-serif;
    }

    .conversation-label3 {
        color: orchid;
        font-size: 10px;
        font-family: Verdana, Arial, sans-serif;
    }

    .conversation-label4 {
        color: black;
        font-size: 10px;
        font-family: Verdana, Arial, sans-serif;
    }

    .conversation-table {
        font-family: Verdana, Arial, sans-serif;
        font-size: 11px;
    }
    .conversation-table td {
        font-size: 11px;
        padding: 5px 5px 5px 5px;
    }

    .light-gray-border {
        border-color: #bbb;
        border-style: solid;
        border-width: 1px 1px 1px 1px;
    }

    .light-gray-border-bottom {
        border-color: #bbb;
        border-style: solid;
        border-width: 0px 0px 1px 0px;
    }

    .small-description {
        font-size: 11px;
        font-family: Verdana, Arial, sans-serif;
        color: #666;
    }

   .description {
        font-size: 12px;
        font-family: Verdana, Arial, sans-serif;
        color: #666;
    }


      .pagination {
        border-color: #bbb;
        border-style: solid;
        border-width: 0px 0px 1px 0px;
        font-size: 10px;
        font-family: Verdana, Arial, sans-serif;

    }

    .content {
        border-color: #bbb;
        border-style: solid;
        border-width: 0px 0px 1px 0px;
    }

    /* Default DOM Tooltip Style */
    div.domTT {
        border: 1px solid #bbb;
        background-color: #FFFBE2;
        font-family: Arial, Helvetica sans-serif;
        font-size: 9px;
        padding: 5px;
    }

    div.domTT .caption {
        font-family: serif;
        font-size: 12px;
        font-weight: bold;
        padding: 1px 2px;
        color: #FFFFFF;
    }

    div.domTT .contents {
        font-size: 12px;
        font-family: sans-serif;
        padding: 3px 2px;
    }

    .textfield {
        font-size: 11px;
        font-family: Verdana, Arial, sans-serif;
        height: 20px;
        background: #efefef;
    }

    .keyword-field {
        font-size: 11px;
        font-family: Verdana, Arial, sans-serif;
        height: 20px;
    }

    #searchResults {
        margin: 10px 0px 10px 0px;
    }

    #searchResults h3 {
        font-size: 14px;
        padding: 0px;
        margin: 0px 0px 2px 0px;
        color: #555555;
    }

    #searchResults p.resultDescription {
        margin: 0px 0px 12px 0px;
    }
</style>

<style type="text/css" title="setupStyle" media="screen">
	@import "../../style/lightbox.css";
</style>

<script language="JavaScript" type="text/javascript" src="../../js/lightbox.js"></script>

<script type="text/javascript">
    var selectedConversation;

    function showConversation(conv) {
        selectedConversation = conv;
        conversations.getConversationInfo(showConv, conv, true);
    }

    function showConv(results) {
        $('chat-viewer-empty').style.display = 'none';
        $('chat-viewer').style.display = '';
        if (results.allParticipants != null) {
            $('con-participant1').innerHTML = results.allParticipants.length;
            $('con-participant2').innerHTML = '(<a href="#" onclick="showOccupants(' + results.conversationID + ', 0);return false;">view</a>)';
        }
        else {
            $('con-participant1').innerHTML = results.participant1 + ',';
            $('con-participant2').innerHTML = results.participant2;
        }
        $('con-chatTime').innerHTML = results.date;
        $('conversation-body').innerHTML = results.body;
        $('con-noMessages').innerHTML = results.messageCount;
        $('con-duration').innerHTML = results.duration;
        <% if (conversationManager.isArchivingEnabled()) { %>
            $('con-chat-link').innerHTML = '<a href="conversation?conversationID='+selectedConversation+'" class="very-small-label"  style="text-decoration:none" target=_blank>View PDF</a>';
        <% } else { %>
            Element.hide('pdf-image');
        <% } %>
    }

    function showOccupants(conversationID, start) {
        var aref = document.getElementById('lbmessage');
        aref.href = 'archive-conversation-participants.jsp?conversationID=' + conversationID + '&start=' + start;
        var lbCont = document.getElementById('lbContent');
        if (lbCont != null) {
            document.getElementById('lightbox').removeChild(lbCont);
        }
        lb = new lightbox(aref);
        lb.activate();
    }

    function grayOut(ele) {
        if (ele.value == 'Any') {
            ele.style.backgroundColor = "#FFFBE2";
        }
        else {
            ele.style.backgroundColor = "#ffffff";
        }
    }
</script>
<script type="text/javascript" src="/js/behaviour.js"></script>
<script type="text/javascript">
    // Add a nice little rollover effect to any row in a jive-table object. This will help
    // visually link left and right columns.

    var selectedElement;

    var myrules = {
        '.conversation-table TR' : function(el) {
            var backgroundColor;
            var selected = false;
            el.onmouseover = function() {

                if (selectedElement != null && selectedElement == this) {
                    return;
                }
                backgroundColor = this.style.backgroundColor;
                this.style.backgroundColor = '#dedede';
                this.style.cursor = 'pointer';
            }

            el.onmouseout = function() {
                if (selectedElement != this) {
                    this.style.backgroundColor = backgroundColor;
                }
            }

            el.onmousedown = function() {
                this.style.backgroundColor = '#fffBc2';
                if (selectedElement != null) {
                    selectedElement.style.backgroundColor = backgroundColor;
                }
                selectedElement = this;
            }
        }
    };

    var textfieldRules = {
        '.textfield' : function(el) {
            el.onblur = function() {
                var va = el.value;
                if (va.length == 0 || va == 'Any') {
                    this.style.backgroundColor = '#efefef';
                    el.value = "<%= anyText%>";
                }
                else {
                    this.style.backgroundColor = '#ffffff';
                }
            }

            el.onfocus = function() {
                var va = el.value;
                if (va == 'Any') {
                    this.style.backgroundColor = '#ffffff';
                    el.value = "";
                }
            }
        }
    };

    Behaviour.register(textfieldRules);
    Behaviour.register(myrules);
</script>
<style type="text/css">
	@import "style/style.css";
</style>
</head>
<body>
<a href="archive-conversation-participants.jsp?conversationID=" id="lbmessage" title="<fmt:message key="archive.group_conversation.participants" />" style="display:none;"></a>

<form action="suspect-search.jsp" name="f">
<!-- Search Table -->
<div>
<table class="stat">
<tr valign="top">
<td>
    <table>
        <tr>
            <td colspan="3">
                <img src="images/icon_daterange.gif" align="absmiddle" alt="" style="margin: 0px 4px 0px 2px;"/>
                <b><fmt:message key="suspect.search.daterange" /></b>
                <a onmouseover="domTT_activate(this, event, 'content',
                    '<fmt:message key="suspect.search.daterange.tooltip"/>',
                    'trail', true, 'direction', 'northeast', 'width', '220');"><img src="images/icon_help_14x14.gif" vspace="2" align="texttop"/></a>
            </td>
        </tr>
        <tr valign="top">
            <td><fmt:message key="suspect.search.daterange.start" /></td>
            <td>
                <input type="text" id="startDate" name="startDate" size="13"
                       value="<%= startDate != null ? startDate :
                       LocaleUtils.getLocalizedString("suspect.search.daterange.any", "monitoring")%>" class="textfield"/><br/>
                <span class="jive-description"><fmt:message key="suspect.search.daterange.format" /></span>
            </td>
            <td>
                <img src="images/icon_calendarpicker.gif" vspace="3" id="startDateTrigger">
            </td>
        </tr>
        <tr valign="top">
            <td><fmt:message key="suspect.search.daterange.end" /></td>
            <td>
                <input type="text" id="endDate" name="endDate" size="13"
                       value="<%= endDate != null ? endDate :
                       LocaleUtils.getLocalizedString("suspect.search.daterange.any", "monitoring") %>" class="textfield"/><br/>
                <span class="jive-description"><fmt:message key="suspect.search.daterange.format" /></span>
            </td>
            <td>
                <img src="images/icon_calendarpicker.gif" vspace="3" id="endDateTrigger">
            </td>
        </tr>
    </table>
</td>

<td>
    <td width="0" height="100%" valign="middle">
        <div class="verticalrule"></div>
    </td>
</td>

<td>
    <table>
        <tr>
            <td colspan="3">
            <img src="images/icon_participants.gif" align="absmiddle" alt="" style="margin-right: 4px;"/>
                <b>Conversation Limit</b>
                <a onmouseover="domTT_activate(this, event, 'content',
                    'Enter conversation limits',
                    'trail', true, 'direction', 'northeast', 'width', '220');"><img src="images/icon_help_14x14.gif" vspace="2" align="texttop"/></a>
            </td>
        </tr>
        <tr valign="top">
            <td>Message Count</td>
            <td>
                <input type="text" id="txtMessageCount" name="txtMessageCount" size="13" value="<%= txtMessageCount %>" class="textfield"/><br/>
                <span class="jive-description">The maximum number of messages.</span>
            </td>
            <td>
            </td>
        </tr>
        <tr valign="top">
            <td>Message Time</td>
            <td>
                <input type="text" id="txtMaxTime" name="txtMaxTime" size="13" value="<%= txtMaxTime %>" class="textfield"/><br/>
                <span class="jive-description">The maximum number of minutes.</span>
            </td>
            <td>
            </td>
        </tr>
    </table>
</td>

</tr>
</table>
</div>
<input type="submit" name="submitForm" value="<fmt:message key="suspect.search.submit" />" class="small-text"/>


<input type="hidden" name="start"  />
<input type="hidden" name="range"  />
<input type="hidden" name="parseRange" />
</form>

<%
    // Code for the searches.

%>

<% if (conversations != null && conversations.size() > 0) { %>
<table id="searchResults" width="100%" style="<%= conversations == null ? "display:none;" : "" %>">
    <tr>
        <td colspan="2">
            <h3><fmt:message key="suspect.search.results" /> <%= conversations.size() %></h3>
            <p class="resultDescription">
                <fmt:message key="suspect.search.results.description">
                    <fmt:param value="<%= conversations.size()%>" />
                </fmt:message>
            </p>
        </td>
    </tr>
    <tr valign="top">
        <td width="300">
            <!-- Search Result Table -->
            <table cellspacing="0" class="light-gray-border">
                <tr class="light-gray-border-bottom">
                    <td class="light-gray-border-bottom">
                        <%
                            int endPoint = (start + range) > conversations.size() ? conversations.size() : (start + range);
                        %>
                        <span class="small-label-with-padding">
                            <%= start + 1%> - <%= endPoint %> <fmt:message key="suspect.search.results.xofy" />
                            <%= conversations.size()%></span>
                    </td>
                    <td align="right" nowrap class="light-gray-border-bottom" style="padding-right:3px;">
                          <%  if (numPages > 1) { %>

                        <p>
                            <%  int num = 5 + curPage;
                                int s = curPage - 1;
                                if (s > 5) {
                                    s -= 5;
                                }
                                if (s < 5) {
                                    s = 0;
                                }
                                if (s > 2) {
                            %>
                            <a href="javascript:submitFormAgain('0', '<%= range%>');">1</a> ...

                            <%
                                }
                                int i = 0;
                                for (i = s; i < numPages && i < num; i++) {
                                    String sep = ((i + 1) < numPages) ? " " : "";
                                    boolean isCurrent = (i + 1) == curPage;
                            %>
                            <a href="javascript:submitFormAgain('<%= (i*range) %>', '<%= range %>');"
                               class="<%= ((isCurrent) ? "small-label" : "small-label-no-bold") %>"
                                ><%= (i + 1) %></a><%= sep %>

                            <%  } %>

                            <%  if (i < numPages) { %>

                            ... <a href="javascript:submitFormAgain('<%= ((numPages-1)*range) %>', '<%= range %>');"><%= numPages %></a>

                            <%  } %>
                        </p>

                        <%  } else { %>
                        &nbsp;
                        <%  } %>

                    </td>
                </tr>
                <tr>
                    <td colspan="2" align="left">
                        <div style="HEIGHT:300px;width:285px;OVERFLOW:auto">
                            <table cellpadding="3" cellspacing="0" width="100%" class="conversation-table">

                                <%
                                    int i = 1;
                                    int end = start + range + 1;
                                    for (Conversation conversation : conversations) {
                                        if(i == end){
                                            break;
                                        }
                                        else if(i < start){
                                            i++;
                                            continue;
                                        }
                                        Map<String, JID> participants = getParticipants(conversation);
                                        String color = "#FFFFFF";
                                        if (i % 2 == 0) {
                                            color = "#F0F0F0";
                                        }

                                %>
                                <tr id="<%= conversation.getConversationID()%>" valign="top" bgcolor="<%= color%>" onclick="showConversation('<%= conversation.getConversationID() %>'); return false;">
                                    <td><b><%= i %>.</b></td>
                                    <td width="98%">
                                        <% if (conversation.getRoom() == null) { %>
                                            <%
                                                Iterator iter = participants.keySet().iterator();
                                                while (iter.hasNext()) {
                                                    String name = (String)iter.next();
                                            %>
                                            <%= name%><br/>
                                            <% } %>
                                        <% } else { %>
                                            <i><fmt:message key="suspect.search.group_conversation">
                                                <fmt:param value="<%= conversation.getRoom().getNode() %>" />
                                            </fmt:message></i><br>
                                            <fmt:message key="suspect.search.results.participants" /> <%= conversation.getParticipants().size() %>
                                        <% } %>
                                    </td>
                                    <td align="right" nowrap>
                                        <%= getFormattedDate(conversation)%>
                                    </td>
                                </tr>
                                <% i++;
                                } %>
                            </table>
                        </div>
                    </td>
                </tr>
            </table>
        </td>
        <td>


             <!-- Conversation Viewer (empty) -->
            <div id="chat-viewer-empty">
                <table class="light-gray-border" width="100%" style="height: 323px;">
                    <tr>
                        <td align="center" valign="top" bgcolor="#fafafa">
                            <br>
                            <p>Select a conversation to the left to view details.</p></td>
                    </tr>
                </table>
            </div>

            <!-- Conversation Viewer -->
            <div id="chat-viewer" style="display:none;">
                <table class="light-gray-border" cellspacing="0">
                    <tr valign="top">
                        <td width="99%" bgcolor="#f0f0f0" class="light-gray-border-bottom" style="padding: 3px 2px 4px 5px;">
                            <span class="small-label"><fmt:message key="suspect.search.results.participants" /></span>&nbsp;
                            <span class="small-text" id="con-participant1"></span>&nbsp;
                            <span class="small-text" id="con-participant2"></span><br/>
                            <span class="small-label"><fmt:message key="suspect.search.results.messagecount" /></span>&nbsp;
                            <span class="small-text" id="con-noMessages"></span><br/>
                            <span class="small-label"><fmt:message key="suspect.search.results.date" /></span>&nbsp;
                            <span class="small-text" id="con-chatTime"></span><br/>
                            <span class="small-label"><fmt:message key="suspect.search.results.duration" /></span>&nbsp;
                            <span class="small-text" id="con-duration"></span>
                        </td>
                        <td id="pdf-image" width="1%" bgcolor="#f0f0f0" nowrap align="right" class="light-gray-border-bottom" style="padding: 4px 3px 3px 0px;">
                            <img src="images/icon_pdf.gif" alt="" align="texttop" border="0" /> <span id="con-chat-link"></span>
                        </td>

                    </tr>
                    <tr>
                        <td colspan="2">
                            <div class="conversation" id="conversation-body" style="HEIGHT:241px;width:100%;OVERFLOW:auto">
                            </div>
                        </td>
                    </tr>
                </table>
            </div>


        </td>
    </tr>
</table>

<% } else if(submit) { %>
<span class="description">
<fmt:message key="suspect.search.results.none" />
</span>
<% } %>


<script type="text/javascript">
    //grayOut(f.participant1);
   //grayOut(f.participant2);
    grayOut(f.startDate);
    grayOut(f.endDate);

     function catcalc(cal) {
        var endDateField = $('endDate');
        var startDateField = $('startDate');

        var endTime = new Date(endDateField.value);
        var startTime = new Date(startDateField.value);
        if(endTime.getTime() < startTime.getTime()){
            alert("<fmt:message key="suspect.search.daterange.error" />");
            startDateField.value = "<fmt:message key="suspect.search.daterange.any" />";
        }
    }

    Calendar.setup(
    {
        inputField  : "startDate",         // ID of the input field
        ifFormat    : "%m/%d/%y",    // the date format
        button      : "startDateTrigger",       // ID of the button
        onUpdate    :  catcalc
    });

    Calendar.setup(
    {
        inputField  : "endDate",         // ID of the input field
        ifFormat    : "%m/%d/%y",    // the date format
        button      : "endDateTrigger",       // ID of the button
        onUpdate    :  catcalc
    });
</script>
</body>
</html>

<%!
    public TreeMap<String, JID> getParticipants(Conversation conv) {
        final TreeMap<String, JID> participants = new TreeMap<String, JID>();
        for (JID jid : conv.getParticipants()) {
            try {
                if (jid == null) {
                    continue;
                }
                String identifier = jid.toBareJID();
                try {
                    identifier = UserNameManager.getUserName(jid, jid.toBareJID());
                } catch (UserNotFoundException e) {
                    // Ignore
                }
                participants.put(identifier, jid);
            }
            catch (Exception e) {
                Log.error(e);
            }

        }

        return participants;
    }

    public String getFormattedDate(Conversation conv) {
        return JiveGlobals.formatDate(conv.getStartDate());
    }
%>