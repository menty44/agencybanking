<!DOCTYPE html>
<%-- 
  Copyright (c) impalapay Ltd., June 23, 2014
  
  @author eugene chimita, eugenechimita@impalapay.com
--%>

<%@page
    import="com.impalapay.airtel.accountmgmt.pagination.TransactionPage"%>

<%@page
        import="com.impalapay.airtel.accountmgmt.admin.pagination.TransactionPaginator"%>

<%@page import="com.impalapay.airtel.beans.transaction.TransactionStatus"%>
<%@page import="com.impalapay.airtel.beans.transaction.Transaction"%>

<%@page import="com.impalapay.airtel.beans.accountmgmt.Account"%>
<%@page import="com.impalapay.airtel.beans.geolocation.Country"%>

<%@page import="com.impalapay.airtel.accountmgmt.session.SessionStatistics"%>
<%@page import="com.impalapay.airtel.accountmgmt.admin.SessionConstants"%>

<%@page import="com.impalapay.airtel.cache.CacheVariables"%>

<%@page import="org.apache.commons.lang3.StringUtils" %>



<%@page import="net.sf.ehcache.Cache" %>
<%@page import="net.sf.ehcache.CacheManager" %>
<%@page import="net.sf.ehcache.Element" %>
<%@page import="java.text.SimpleDateFormat" %>

<%@page import="java.util.Map"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.List"%>
<%@page import="java.util.HashMap"%>

<%
    // The following is for session management.    
    if (session == null) {
        response.sendRedirect("../index.jsp");
    }

    String sessionKey = (String) session.getAttribute(SessionConstants.ADMIN_SESSION_KEY);

    if (StringUtils.isEmpty(sessionKey)) {
        response.sendRedirect("../index.jsp");
    }

    session.setMaxInactiveInterval(SessionConstants.SESSION_TIMEOUT);
    response.setHeader("Refresh", SessionConstants.SESSION_TIMEOUT + "; url=../logout");
    // End of session management code



    CacheManager mgr = CacheManager.getInstance();

    Cache statisticsCache = mgr.getCache(CacheVariables.CACHE_ALL_ACCOUNTS_STATISTICS);

    Cache countryCache = mgr.getCache(CacheVariables.CACHE_COUNTRY_BY_UUID);


     //These HashMaps contains the UUIDs of Countries as keys and the country code of countries as values
    HashMap<String, String> countryHash = new HashMap<String, String>();

    Account account = new Account();
    SessionStatistics statistics = new SessionStatistics();
    List keys;
    Country country;
    int count = 0; // A generic counter

    Element element;

     if ((element = statisticsCache.get(CacheVariables.CACHE_ALL_ACCOUNTS_STATISTICS_KEY)) != null) {
        statistics = (SessionStatistics) element.getObjectValue();
    }
    
  
   //fetch from cache
    
    keys = countryCache.getKeys();
    for(Object key : keys) {
    element = countryCache.get(key);
    country = (Country) element.getObjectValue();
    countryHash.put(country.getUuid(), country.getCountrycode());	        
     }

     count = statistics.getTransactionCountTotal();
     //count = 15;
     
  
      TransactionPaginator paginator = new TransactionPaginator();

      TransactionPage transactionPage;
      List<Transaction> transactionList;

      int transactionCount; // The current count of transactions
   
                        if (count == 0) { // This user has no transactions in his/her account
                            transactionPage = new TransactionPage();
                            transactionList = new ArrayList<Transaction>();
                            transactionCount = 0;

                        } else {
                            transactionPage = (TransactionPage) session.getAttribute("currentAdminTransactionPage");

                           // String referrer = request.getHeader("referer");
                            String pageStr = (String) request.getParameter("page");

                            // We are to give the first page
                            if (transactionPage == null
                                    // || !StringUtils.endsWith(referrer, "transaction.jsp")
                                    || StringUtils.equalsIgnoreCase(pageStr, "first")) {
                                transactionPage = paginator.getFirstPage();

                                // We are to give the last page
                            } else if (StringUtils.equalsIgnoreCase(pageStr, "last")) {
                                transactionPage = paginator.getLastPage();


                                // We are to give the previous page
                            } else if (StringUtils.equalsIgnoreCase(pageStr, "previous")) {
                                transactionPage = paginator.getPrevPage(transactionPage);

                                // We are to give the next page 
                            } else {
                                transactionPage= paginator.getNextPage(transactionPage);
                            }

                            session.setAttribute("currentAdminTransactionPage", transactionPage);

                            transactionList = transactionPage.getContents();
                            transactionCount = (transactionPage.getPageNum() - 1) * transactionPage.getPagesize() + 1;
                        }
%>

<html lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <title>dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <meta name="layout" content="main"/>
    
    <script type="text/javascript" src="http://www.google.com/jsapi"></script>

    <script src="../js/jquery/jquery-1.8.2.min.js" type="text/javascript" ></script>
    <link href="../css/customize-template.css" type="text/css" media="screen, projection" rel="stylesheet" />

    <style>
        #body-content { padding-top: 40px;}
    </style>
</head>
    <body>
        <div class="navbar navbar-fixed-top">
            <div class="navbar-inner">
                <div class="container">
                    <button class="btn btn-navbar" data-toggle="collapse" data-target="#app-nav-top-bar">
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                    <a href="dashboard.html" class="brand">main dashboard</a>
                    <div id="app-nav-top-bar" class="nav-collapse">
                        
                        <ul class="nav pull-right">
                            <li>
                                <a href="login.html">Logout</a>
                            </li>
                            
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <div id="body-container">
            <div id="body-content">
                
 
                   
                
                
        <section class="nav nav-page">
        <div class="container">
            <div class="row">
                
                <div class="page-nav-options">
                    <div class="span12">
                        
                        <ul class="nav nav-tabs">
                            <li class="active">
                                <a href="dashboard.jsp"><i class="icon-home"></i>Dashboard</a>
                            </li>
                          
                            <li><a href="accounts/accountsIndex.jsp">Accounts</a></li>
                            <li><a href="#">Topup</a></li>
                            <li><a href="#">Setting</a></li>
                            <li><a href="#">Help</a></li>
                            <li><a href="#">Search Transaction</a></li>
                        </ul>
 <div align="right"> 

                    <form name="logoutForm" method="post" action="../logout">  
                        <p><a href="" class="btn btn-primary" >logged-in as Administrator:&nbsp;<%=sessionKey%>&nbsp;</a>
                        <input type="submit" class="btn btn-danger" name="logout" id="logout" value="Logout"> </p>         
                    </form>
                </div>   
                    </div>
                </div>
            </div>
        </div>
    </section>
    <section class="page container">
    
            
                <div class="alert alert-success">
                    
                    All Transactions By all IMTS
                   
                </div>
           
     
        
        

        <div class="row">
            <div class="span16">
                <div class="box">
                    <div class="box-header">
                        <form name="pageForm" method="post" action="transaction.jsp">
                                                                <%
                                if (!transactionPage.isFirstPage()) {
                                                                %>
                                                                <input class="btn btn-primary" type="submit" name="page"
                                                                       value="First" /> <input class="btn btn-primary" type="submit"
                                                                       name="page" value="Previous" />
                                                                <%                                    }
                                                                %>
                                                                <span class="pageInfo">Page <span
                                                                        class="pagePosition currentPage"><%= transactionPage.getPageNum()%></span>
                                                                    of <span class="pagePosition"><%= transactionPage.getTotalPage()%></span>
                                                                </span>
                                                                <%
                                if (!transactionPage.isLastPage()) {
                                                                %>
                                                                <input class="btn btn-primary" type="submit" name="page"
                                                                       value="Next"> <input class="btn btn-primary" type="submit"

                                                                       name="page" value="Last">
                                                                <%                                    
                                }
                                                                %>
                                                            </form>
                     
                    </div>
                     
                   <table class="table table-hover tablesorter">
                            <thead>
                                <tr>
                                   <th></th>
                           <th>transaction Uuid</th>
                           <th>Source country code</th>
                           <th>Sender name</th>
                           <th>Recipient phone number</th>
                           <th>Amount</th>
                           <th>Recipient Country Code</th>
                           <th>Sender Token</th>
                           <th>Server Time</th>
                           <th>Client Time</th>
                           </tr>
                            </thead>
                            <tbody>
                            <%
                            count = transactionList.size();


                           // out.println(count);
                            for (int j = 0; j < count; j++) {
                                out.println("<tr class='alert alert-info'>");
                                out.println("<td>" + transactionCount + "</td>");
                                out.println("<td>" + transactionList.get(j).getUuid() + "</td>");
                                out.println("<td>" + transactionList.get(j).getSourceCountrycode() + "</td>");
                                out.println("<td>" + transactionList.get(j).getSenderName() + "</td>");
                                out.println("<td>" + transactionList.get(j).getRecipientMobile() + "</td>");
                                out.println("<td>" + transactionList.get(j).getAmount() + "</td>");
                                out.println("<td>" + countryHash.get(transactionList.get(j).getRecipientCountryUuid()) + "</td>");
                                out.println("<td>" + transactionList.get(j).getSenderToken() + "</td>");
                                out.println("<td>" + transactionList.get(j).getClientTime() + "</td>");
                                out.println("<td>" + transactionList.get(j).getServerTime() + "</td>");
                                out.println("</tr>");
                                transactionCount++;
                            }
                                                        %>
                            
                               
                            
                            </tbody>
                        </table> 
                   
                </div>
            </div>
        </div>
        
        
    </section>

    

            </div>
        </div>

        <div id="spinner" class="spinner" style="display:none;">
            Loading&hellip;
        </div>

        <footer class="application-footer">
            <div class="container">
                <p>Application Footer</p>
                <div class="disclaimer">
                    <p>This is an example disclaimer. All right reserved.</p>
                    <p>Copyright © keaplogik 2011-2012</p>
                </div>
            </div>
        </footer>
        
        <script src="../js/bootstrap/bootstrap-transition.js" type="text/javascript" ></script>
        <script src="../js/bootstrap/bootstrap-alert.js" type="text/javascript" ></script>
        <script src="../js/bootstrap/bootstrap-modal.js" type="text/javascript" ></script>
        <script src="../js/bootstrap/bootstrap-dropdown.js" type="text/javascript" ></script>
        <script src="../js/bootstrap/bootstrap-scrollspy.js" type="text/javascript" ></script>
        <script src="../js/bootstrap/bootstrap-tab.js" type="text/javascript" ></script>
        <script src="../js/bootstrap/bootstrap-tooltip.js" type="text/javascript" ></script>
        <script src="../js/bootstrap/bootstrap-popover.js" type="text/javascript" ></script>
        <script src="../js/bootstrap/bootstrap-button.js" type="text/javascript" ></script>
        <script src="../js/bootstrap/bootstrap-collapse.js" type="text/javascript" ></script>
        <script src="../js/bootstrap/bootstrap-carousel.js" type="text/javascript" ></script>
        <script src="../js/bootstrap/bootstrap-typeahead.js" type="text/javascript" ></script>
        <script src="../js/bootstrap/bootstrap-affix.js" type="text/javascript" ></script>
        <script src="../js/bootstrap/bootstrap-datepicker.js" type="text/javascript" ></script>
        <script src="../js/jquery/jquery-tablesorter.js" type="text/javascript" ></script>
        <script src="../js/jquery/jquery-chosen.js" type="text/javascript" ></script>
        <script src="../js/jquery/virtual-tour.js" type="text/javascript" ></script>
        <script type="text/javascript">
        $(function() {
            $('#sample-table').tablesorter();
            $('#datepicker').datepicker();
            $(".chosen").chosen();
        });
    </script>

    </body>
</html>
