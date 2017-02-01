<!DOCTYPE html>
<%--
  Copyright (c) impalapay Ltd., June 23, 2014

  @author eugene chimita, eugenechimita@impalapay.com
--%>

<%@page import="com.impalapay.airtel.accountmgmt.pagination.TransactionPage"%>
<%@page import="com.impalapay.airtel.accountmgmt.admin.pagination.TransactionPaginator"%>
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
    Cache accountsCache = mgr.getCache(CacheVariables.CACHE_ACCOUNTS_BY_USERNAME);
    Cache statusCache = mgr.getCache(CacheVariables.CACHE_TRANSACTIONSTATUS_BY_UUID);


     //These HashMaps contains the UUIDs of Countries as keys and the country code of countries as values
    HashMap<String, String> countryHash = new HashMap<String, String>();
    HashMap<String, String> accountHash = new HashMap<String, String>();
    HashMap<String, String> statusHash = new HashMap<String, String>();

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

    keys = accountsCache.getKeys();
    for(Object key : keys) {
    element = accountsCache.get(key);
    account = (Account) element.getObjectValue();
    accountHash.put(account.getUuid(), account.getFirstName());
     }

    TransactionStatus transactionStatus;
    keys = statusCache.getKeys();
    for(Object key : keys) {
    element = statusCache.get(key);
    transactionStatus = (TransactionStatus) element.getObjectValue();
    statusHash.put(transactionStatus.getUuid(), transactionStatus.getDescription());
    }

    count = statistics.getTransactionCountTotal();
    //count = 15;


    TransactionPaginator paginator = new TransactionPaginator();
    TransactionPage transactionPage;
    List<Transaction> transactionList;
    int transactionCount; // The current count of transactions
    if (count == 0) {
       // This user has no transactions in his/her account
          transactionPage = new TransactionPage();
          transactionList = new ArrayList<Transaction>();
          transactionCount = 0;
          } else {
          transactionPage = (TransactionPage) session.getAttribute("currentAdminTransactionPage");
          String referrer = request.getHeader("referer");
          String pageStr = (String) request.getParameter("page");

          // We are to give the first page
          if (transactionPage == null
              || !StringUtils.endsWith(referrer, "alltransaction.jsp")
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
    <!-- Meta, title, CSS, favicons, etc. -->
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>ImpalaPay | Transactions</title>
    <link  rel="icon" type="image/png"  href="../images/logo.jpg">

    <!-- Bootstrap core CSS -->

    <link href="../css/bootstrap.min.css" rel="stylesheet">

    <link href="../fonts/css/font-awesome.min.css" rel="stylesheet">
    <link href="../css/animate.min.css" rel="stylesheet">

    <!-- Custom styling plus plugins -->
    <link href="../css/custom.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="../css/maps/jquery-jvectormap-2.0.1.css" />
    <link href="../css/icheck/flat/green.css" rel="stylesheet">
    <link href="../css/floatexamples.css" rel="stylesheet" />

    <script src="../js/jquery.min.js"></script>

    <!--[if lt IE 9]>
        <script src="../assets/js/ie8-responsive-file-warning.js"></script>
        <![endif]-->

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
          <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
          <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
        <![endif]-->

</head>


<body class="nav-md">

    <div class="container body">


        <div class="main_container">

            <div class="col-md-3 left_col">
                <div class="left_col scroll-view">


                    <div class="clearfix"></div>

                    <!-- menu prile quick info -->
                    <div class="profile">
                        <div class="profile_pic">
                            <img src="../images/img.png" alt="..." class="img-circle profile_img">
                        </div>
                        <div class="profile_info">
                            <span>Welcome,</span>
                            <h2><%=sessionKey%></h2>
                        </div>
                    </div>
                    <!-- /menu prile quick info -->

                    <br />

                            <!-- sidebar menu -->
                            <div id="sidebar-menu" class="main_menu_side hidden-print main_menu">

                  <div class="menu_section">

                    <ul class="nav side-menu">
                        <li><a><i class="fa fa-area-chart"></i> Home <span class="fa fa-chevron-down"></span></a>
                            <ul class="nav child_menu" style="display: none">
                                <li><a href="../dashboard.jsp">Dashboard</a>
                                </li>
                                </li>
                            </ul>
                        </li>
                        <li><a><i class="fa fa-users"></i>Personal<span class="fa fa-chevron-down"></span></a>
                            <ul class="nav child_menu" style="display: none">
                                <li><a href="profile.jsp">Profile</a>
                                </li>
                                  <li><a href="changepassword.jsp">Change Password</a>
                                </li>
                                 <li><a href="emailnotify.jsp">Email Notification</a>
                                </li>
                            </ul>
                        </li>
                        <li><a><i class="fa fa-users"></i>Accounts<span class="fa fa-chevron-down"></span></a>
                            <ul class="nav child_menu" style="display: none">
                                <li><a href="currencies.jsp">Manage Currencies</a>
                                </li>
                                  <li><a href="addManagementAccount.jsp">Manage Accounts</a>
                                </li>
                                 <li><a href="systemaccounts.jsp">System Accounts</a>
                                </li>
                                <li><a href="schedulepayments.jsp">Schedule Payments</a>
                                </li>
                                  <li><a href="systempayments.jsp">System Payments</a>
                                </li>
                                 <li><a href="memberpayments.jsp">Member Payments</a>
                                </li>
                                </li>
                                 <li><a href="accountfees.jsp">Account Fees</a>
                                </li>
                                <li><a href="manageloans.jsp">Manage Loans</a>
                                </li>
                                  <li><a href="loanpayment.jsp">Loan Payments</a>
                                </li>

                            </ul>
                        </li>
                        <li><a><i class="fa fa-users"></i>User/UserGroup<span class="fa fa-chevron-down"></span></a>
                            <ul class="nav child_menu" style="display: none">
                                <li><a href="accountsIndex.jsp">Manage Members</a>
                                </li>
                                  <li><a href="bulkactions.jsp">Bulk Action</a>
                                </li>
                                 <li><a href="importmembers.jsp">Import Members</a>
                                </li>
                                <li><a href="manageadmins.jsp">Manage Admins</a>
                                </li>
                                  <li><a href="connectedusers.jsp">Connected Users</a>
                                </li>
                                 <li><a href="pendingmembers.jsp">Pending Members</a>
                                </li>
                                <li><a href="registrationagreements.jsp">Registration Agreements</a>
                                </li>
                                  <li><a href="permissiongroups.jsp">Permission Groups</a>
                                </li>
                                 <li><a href="loangroups.jsp">Loan Groups</a>
                                </li>
                                <li><a href="memberrecords.jsp">Member Records Type</a>
                                </li>
                            </ul>
                        </li>
                        <li><a><i class="fa fa-database"></i>Access Devices<span class="fa fa-chevron-down"></span></a>
                            <ul class="nav child_menu" style="display: none">
                                <li><a href="alltransaction.jsp">View All Transactions</a>
                                </li>
                                 <li><a href="updatestatus.jsp">Adjust Transaction Status</a>
                                </li>
                            </ul>
                        </li>
                        <!--<li><a><i class="fa fa-money"></i>Manage Balance<span class="fa fa-chevron-down"></span></a>
                            <ul class="nav child_menu" style="display: none">
                                <li><a href="accounts/addFloat.jsp">Adjust Client Balance</a>
                                <li><a href="accounts/floatHistory.jsp">Client Balance History</a>
                            </ul>
                        </li>-->
        <li><a><i class="fa fa-wifi"></i>Messages<span class="fa fa-chevron-down"></span></a>
                            <ul class="nav child_menu" style="display: none">
                               <li><a href="addCountry.jsp">Add Country(MNO)</a></li>
                                </li>
                               <li><a href="addmnoprefix.jsp">Define Prefix(MNO)</a></li>
                                </li>
                                 <li><a href="addNetwork.jsp">Add Networks</a></li>
                                </li>
                                <li><a href="addBank.jsp">Add Bank</a></li>
                                </li>
                            </ul>
                        </li>
                        <li><a><i class="fa fa-exclamation-triangle"></i>Settings<span class="fa fa-chevron-down"></span></a>
                            <ul class="nav child_menu" style="display: none">
                                <li><a href="addSessionIp.jsp">Local Setting</a>
                                </li>
                                 <li><a href="systemlog.jsp">Alert Setting</a>
                                </li>
                                <li><a href="mailsettings.jsp">Mail Setting</a>
                                </li>
                                 <li><a href="systemlog.jsp">Log Setting</a>
                                </li>
                                <li><a href="addSessionIp.jsp">Channels</a>
                                </li>
                                 <li><a href="systemlog.jsp">WebServices Clients</a>
                                </li>
                                <li><a href="addSessionIp.jsp">System Tasks</a>
                                </li>
                            </ul>
                        </li>
                        <li><a><i class="fa fa-exclamation-triangle"></i>Reports<span class="fa fa-chevron-down"></span></a>
                            <ul class="nav child_menu" style="display: none">
                                <li><a href="addSessionIp.jsp">IP-WhiteList/Session-Url</a>
                                </li>
                                 <li><a href="systemlog.jsp">SystemLog History</a>
                                </li>
                            </ul>
                        </li>
                    </ul>
                  </div>

              </div>
                    <!-- /sidebar menu -->

                    <!-- /menu footer buttons -->
                   <!-- <div class="sidebar-footer hidden-small">
                        <a data-toggle="tooltip" data-placement="top" title="Settings">
                            <span class="glyphicon glyphicon-cog" aria-hidden="true"></span>
                        </a>
                        <a data-toggle="tooltip" data-placement="top" title="FullScreen">
                            <span class="glyphicon glyphicon-fullscreen" aria-hidden="true"></span>
                        </a>
                        <a data-toggle="tooltip" data-placement="top" title="Lock">
                            <span class="glyphicon glyphicon-eye-close" aria-hidden="true"></span>
                        </a>
                        <a data-toggle="tooltip" data-placement="top" title="Logout">
                            <span class="glyphicon glyphicon-off" aria-hidden="true"></span>
                        </a>
                    </div>-->
                    <!-- /menu footer buttons -->
                </div>
            </div>

            <!-- top navigation -->
            <div class="top_nav">

                <div class="nav_menu">
                    <nav class="" role="navigation">
                        <div class="nav toggle">
                            <a id="menu_toggle"><i class="fa fa-bars"></i></a>
                        </div>

                        <ul class="nav navbar-nav navbar-right">
                            <li class="">
                                <a href="javascript:;" class="user-profile dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                    <img src="../images/img.png" alt=""><%= sessionKey%>
                                    <span class=" fa fa-angle-down"></span>
                                </a>
                                <ul class="dropdown-menu dropdown-usermenu animated fadeInDown pull-right">
                                    <li>
                                        <form name="logoutForm" method="post" action="../logout">
                                            <p>
                                            <!--<input type="submit" class="btn btn-primary" name="logout" id="logout" value="Logout">-->
                                            <button type="submit" class="btn btn-primary"><i class="fa fa-sign-out pull-right"></i> Log Out</button>

                                            </p>
                                        </form>

                                    </li>
                                </ul>
                            </li>
                        </ul>
                    </nav>
                </div>

            </div>
            <!-- /top navigation -->
<div class="right_col" role="main">
            <div class="">
                                <div class="page-title">
                                    <div class="title_left">
                                        <h3>Transactions</h3>
                                    </div>
                                </div>


                        <div class="row">
                        <div class="col-md-12">
                            <div class="x_panel">
                                <div class="x_content">

                                    <div class="row">


                                                <!-- small box -->
                                                <div class="small-box">
                                                    <div class="inner">
                                                     <i class="icon-eye-open icon-large"></i>
                                                     <h5>all transactions</h5>
                                                        <div align="right">
                                                        <div id="pagination">
                                                            <form name="pageForm" method="post" action="alltransaction.jsp">
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
                                                     </div>

                                                    <div class="x_content">
                                                        <table id="example" class="table table-striped responsive-utilities jambo_table">
                                                        <!--<table class="table table-striped bootstrap-datatable datatable">-->
                                                            <thead>
                                                                <tr class="headings">
                                                                <th></th>
                                                               	<th>transaction Uuid</th>
                                                                <th>Account</th>
                                                                <th>Source country code</th>
                                                                <th>Sender name</th>
                                                                <th>Recipient phone number</th>
                                                                <th>Amount</th>
                                                                <th>Recipient Country Code</th>
                                                                <th>Transaction Status</th>
                                                                <th>Server Time</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <%
                                                                count = transactionList.size();


                                                               // out.println(count);
                                                                for (int j = 0; j < count; j++) {
                                                                    out.println("<tr>");
                                                                    out.println("<td>" + transactionCount + "</td>");
                                                                    out.println("<td>" + transactionList.get(j).getUuid() + "</td>");
                                                                    out.println("<td>" + accountHash.get(transactionList.get(j).getAccountUuid()) + "</td>");
                                                                    out.println("<td>" + transactionList.get(j).getSourceCountrycode() + "</td>");
                                                                    out.println("<td>" + transactionList.get(j).getSenderName() + "</td>");
                                                                    out.println("<td>" + transactionList.get(j).getRecipientMobile() + "</td>");
                                                                    out.println("<td>" + transactionList.get(j).getAmount() + "</td>");
                                                                    out.println("<td>" + countryHash.get(transactionList.get(j).getRecipientCountryUuid()) + "</td>");
                                                                    out.println("<td>" + statusHash.get(transactionList.get(j).getTransactionStatusUuid()) + "</td>");
                                                                    //out.println("<td>" + transactionList.get(j).getClientTime() + "</td>");
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
                                            <!-- ./col -->
                                    </div>

                                </div>
                            </div>
                        </div>
                    </div>



                     <!-- footer content -->
                <footer>
                    <div class="">
                        <p>Copyright@ImpalaPay 2014-2015</p>
                            <a href="#">Terms &amp; Conditions</a> | <a href="#">Privacy
                            Policy</a> | ImpalaPay Ltd <%= Calendar.getInstance().get(Calendar.YEAR)%>. All rights reserved.
                            <!--<img id="madeInKenya" alt="Made in Kenya" src="#" width="100" height="100" />-->
                        </p>
                    </div>
                    <div class="clearfix"></div>
                </footer>

                <!-- /footer content -->
                    </div>

                   <!-- page content -->



            </div>
            <!-- /page content -->

            </div>
            <!-- /page content -->
        </div>

    </div>

    <script src="../js/bootstrap.min.js"></script>

    <!-- chart js -->
    <script src="../js/chartjs/chart.min.js"></script>
    <!-- bootstrap progress js -->
    <script src="../js/progressbar/bootstrap-progressbar.min.js"></script>
    <script src="../js/nicescroll/jquery.nicescroll.min.js"></script>
    <!-- icheck -->
    <script src="../js/icheck/icheck.min.js"></script>

    <script src="../js/custom.js"></script>

</body>

</html>
