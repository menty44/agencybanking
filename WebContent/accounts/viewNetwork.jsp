<!DOCTYPE html>
<%--
  Copyright (c) impalapay Ltd., June 23, 2014

  @author eugene chimita, eugenechimita@impalapay.com
--%>
<%@page import="com.impalapay.airtel.accountmgmt.admin.pagination.network.NetworkPage"%>
<%@page import="com.impalapay.airtel.accountmgmt.admin.pagination.network.SearchNetworkPaginator"%>
<%@page import="com.impalapay.beans.network.Network"%>
<%@page import="com.impalapay.airtel.beans.geolocation.Country"%>
<%@page import="com.impalapay.airtel.accountmgmt.session.SessionStatistics"%>
<%@page import="com.impalapay.airtel.accountmgmt.admin.SessionConstants"%>



<%@page import="com.impalapay.airtel.cache.CacheVariables"%>
<%@page import="org.apache.commons.lang3.StringUtils" %>

<%@page import="net.sf.ehcache.Cache" %>
<%@page import="net.sf.ehcache.CacheManager" %>
<%@page import="net.sf.ehcache.Element"%>

<%@page import="java.net.URLEncoder"%>

<%@page import="java.util.Map"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.List"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.util.LinkedList"%>

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
    Cache accountsCache = mgr.getCache(CacheVariables.CACHE_ACCOUNTS_BY_USERNAME);
    Cache statisticsCache = mgr.getCache(CacheVariables.CACHE_ALL_ACCOUNTS_STATISTICS);
    Cache countryCache = mgr.getCache(CacheVariables.CACHE_COUNTRY_BY_UUID);
    Cache networkCache = mgr.getCache(CacheVariables.CACHE_NETWORK_BY_UUID);


    //These HashMaps contains the UUIDs of Countries as keys and the country code of countries as values
    HashMap<String, String> countryHash = new HashMap<String, String>();
    HashMap<String, String> statusHash = new HashMap<String, String>();

    List keys;
    int count = 0;  // Generic counter

    int networkCount = 0; // The current count of the Transactions

    Element element;

	NetworkPage networkPage = new NetworkPage();
	List<Network> networkList = new LinkedList<Network>();

	// returns an enumeration of all the parameter names
	Enumeration enumeration = request.getParameterNames();
	//String uuid = "", msisdn = "", parameterName = "";

	String uuid = "";




                uuid = request.getParameter("uuid");
                //uuid="466b7d564ded49beb85f00e03730a370";
	            count=1;
                //count = countUtils.getTransactionByUuidCount(account, uuid);

                 SearchNetworkPaginator paginator = new SearchNetworkPaginator(uuid);






					    if (count == 0) { // This user has no Transactions in his/her account
						networkPage = new NetworkPage();
						networkList = new ArrayList<Network>();
						networkCount = 0;

					    } else {

						networkPage = (NetworkPage) session.getAttribute("currentNetworkSearchPage");

						String pageStr = (String) request.getParameter("page");

						// We are to give the first page
						if (networkPage == null || pageStr == null
							|| StringUtils.equalsIgnoreCase(pageStr, "first")) {
						    networkPage = paginator.getFirstPage();

						    // We are to give the last page
						} else if (StringUtils.equalsIgnoreCase(pageStr, "last")) {
						    networkPage = paginator.getLastPage();

						    // We are to give the previous page
						} else if (StringUtils.equalsIgnoreCase(pageStr, "previous")) {
						    networkPage = paginator.getPrevPage(networkPage);

						    // We are to give the next page
						} else if (StringUtils.equalsIgnoreCase(pageStr, "next")) {
						    networkPage = paginator.getNextPage(networkPage);
						}

						session.setAttribute("currentNetworkSearchPage", networkPage);

						networkList = networkPage.getContents();
						networkCount = (networkPage.getPageNum() - 1) * networkPage.getPagesize() + 1;


					    }
uuid = "";




%>
<html lang="en">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <!-- Meta, title, CSS, favicons, etc. -->
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>ImpalaPay |Search Results</title>
    <link  rel="icon" type="image/png"  href="images/logo.jpg">

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
                                <li><a><i class="fa fa-users"></i>Accounts<span class="fa fa-chevron-down"></span></a>
                                    <ul class="nav child_menu" style="display: none">
                                        <li><a href="accountsIndex.jsp">Add Account</a>
                                        </li>
                                        <li><a href="addManagementAccount.jsp">Add Management</a>
                                        </li>
                                         <li><a href="addroutedefine.jsp">Account->Network</a>
                                        </li>
                                    </ul>
                                </li>
                                <li><a><i class="fa fa-database"></i> Transactions <span class="fa fa-chevron-down"></span></a>
                                    <ul class="nav child_menu" style="display: none">
                                        <li><a href="alltransaction.jsp">View All Transactions</a>
                                        </li>
                                         <li><a href="updatestatus.jsp">Adjust Transaction Status</a>
                                        </li>
                                    </ul>
                                </li>
                               <!-- <li><a><i class="fa fa-money"></i>Manage Balance<span class="fa fa-chevron-down"></span></a>
                                    <ul class="nav child_menu" style="display: none">
                                        <li><a href="addFloat.jsp">Adjust Client Balance</a>
                    <li><a href="floatHistory.jsp">Client Balance History</a>
                                    </ul>
                                </li>-->
                                <li><a><i class="fa fa-wifi"></i>Manage Networks<span class="fa fa-chevron-down"></span></a>
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
                                <li><a><i class="fa fa-exclamation-triangle"></i>Manage Security<span class="fa fa-chevron-down"></span></a>
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

            <!-- page content -->
            <div class="right_col" role="main">
                <div class="">
                    <div class="clearfix"></div>


                    <div class="row">



                        <div class="clearfix"></div>

                        <div class="span16">
                            <div class="x_panel">
                                <div class="row-fluid">
                                    <div class="pull-left">

                                                        </div>

                                                                <div class="x_content">
 <%
                                                            if (networkList != null) {
                                                                for (Network codes : networkList) {
                                                                %>
                                                                <section class="content invoice">
                                                            <!-- title row -->
                                                            <div class="row">
                                                                <div class="col-xs-12 invoice-header">
                                                                    <h1>
                                                            <small class="pull-right">Date Added: <%=codes.getDateadded()%></small>
                                                            </h1>
                                                                </div>
                                                                <!-- /.col -->
                                                            </div>
                                                            <h4>
                                                            <!-- info row -->
                                                            <div class="row invoice-info">
                                                                <div class="col-sm-4 invoice-col">
                                                                    <address>
                                                                     <b><%=uuid%><br>
                                                                     <b>Authentication</b>
                                                                     <br><br>
                                                                        <strong>NETWORK NAME : </strong>
                                                                        <%=codes.getNetworkname()%>
                                                                        <br><br>
                                                                        <strong>PARTNERS NAME : </strong>
                                                                        <%=codes.getPartnername()%>
                                                                       <br><br>
                                                                        <strong>USERNAME : </strong>
                                                                       <%=codes.getUsername()%>
                                                                       <br><br>
                                                                       <strong>PASSWORD : </strong>
                                                                       <%=codes.getPassword()%>
                                                                       <br><br>
                                                                        <strong>SUPPORT FOREX : </strong>
                                                                        <%=codes.isSupportforex()%>
                                                                       <br><br>
                                                                        <strong>SUPPORT REVERSAL : </strong>
                                                                       <%=codes.isSupportreversal()%>
                                                                       <br><br>
                                                                       <strong>SUPPORT ACCOUNTCHECK : </strong>
                                                                       <%=codes.isSupportaccountcheck()%>
                                                                        <br><br>
                                                                        <strong>SUPPORT QUERYCHECK : </strong>
                                                                       <%=codes.isSupportquerycheck()%>
                                                                       <br><br>
                                                                       <strong>SUPPORT BALANCECHECK : </strong>
                                                                       <%=codes.isSupportbalancecheck()%>
                                                                       <br><br>
                                                                       <strong>COMMISSION AS PERCENTAGE : </strong>
                                                                       <%=codes.isSupportcommissionpercentage()%>
                                                                       <br><br>
                                                                       <strong>STATUS : </strong>
                                                                       <%=codes.getNetworkStatusUuid()%>
                                                                    </address>
                                                                </div>
                                                                <!-- /.col -->
                                                                <div class="col-sm-4 invoice-col">

                                                                    <address>
                                                                     <b>Bridge-Details</b>
                                                                     <br><br>
                                                                        <strong>BRIDGE REMITURL : </strong>
                                                                        <%=codes.getBridgeremitip()%>
                                                                        <br><br>
                                                                        <strong>BRIDGE QUERYURL : </strong>
                                                                        <%=codes.getBridgequeryip()%>
                                                                        <br><br>
                                                                        <strong>BRIDGE BALANCEURL : </strong>
                                                                        <%=codes.getBridgebalanceip()%>
                                                                        <br><br>
                                                                        <strong>BRIDGE REVERSALURL : </strong>
                                                                       <%=codes.getBridgereversalip()%>
                                                                        <br><br>
                                                                        <strong>BRIDGE FOREXURL : </strong>
                                                                        <%=codes.getBridgeforexip()%>
                                                                        <br><br>
                                                                        <strong>BRIDGE ACCOUNTCHECKURL : </strong>
                                                                        <%=codes.getBridgeaccountcheckip()%>
                                                                        <br><br>
                                                                        <strong>EXTRA URL : </strong>
                                                                        <%=codes.getExtraurl()%>
                                                                    </address>

                                                                </div>
                                                                <div class="col-sm-4 invoice-col">

                                                                    <address>
                                                                     <b>Live-Details</b>
                                                                     <br><br>
                                                                        <strong>REMITURL : </strong>
                                                                        <%=codes.getRemitip()%>
                                                                        <br><br>
                                                                        <strong>QUERYURL : </strong>
                                                                        <%=codes.getQueryip()%>
                                                                        <br><br>
                                                                        <strong>BALANCEURL : </strong>
                                                                        <%=codes.getBalanceip()%>
                                                                        <br><br>
                                                                        <strong>REVERSALURL : </strong>
                                                                       <%=codes.getReversalip()%>
                                                                        <br><br>
                                                                        <strong>FOREXURL : </strong>
                                                                        <%=codes.getForexip()%>
                                                                        <br><br>
                                                                        <strong>ACCOUNTCHECKURL : </strong>
                                                                        <%=codes.getAccountcheckip()%>
                                                                        <br><br>
                                                                       <strong>COMMISSION : </strong>
                                                                       <%=codes.getCommission()%>
                                                                    </address>

                                                                </div>
                                                            </div>
                                                          </h4>
                                                            <!-- /.row -->

                                                            <!-- Table row -->

                                                            <!-- /.row -->


                                                            <!-- /.row -->

                                                            <!-- this row will not appear when printing -->
                                                            <div class="row no-print">
                                                                <div class="col-xs-12">
                                                                    <button class="btn btn-default" onclick="window.print();"><i class="fa fa-print"></i> Print</button>
                                                                    <a href="addNetwork.jsp" class="btn btn-success pull-right" role="button"><i class="fa fa-arrow-circle-left"></i>Back</a>

                                                                </div>
                                                            </div>
                                                            </section>

                                                                <%
                                                                    networkCount++;
                                                                }
                                                                }

                                                            %>
                                                                 </div>




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
