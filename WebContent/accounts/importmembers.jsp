<!DOCTYPE html>
<%--
  Copyright (c) impalapay Ltd., June 23, 2014

  @author eugene chimita, eugenechimita@impalapay.com
--%>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.pagination.managementaccount.ManageAccountPage"%>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.pagination.managementaccount.ManageAccountPaginator"%>
<%@ page import="com.impalapay.airtel.beans.accountmgmt.ManagementAccount"%>


<%@ page import="com.impalapay.airtel.beans.accountmgmt.AccountStatus" %>
<%@ page import="com.impalapay.airtel.persistence.accountmgmt.AccountStatusDAO" %>


<%@ page import="com.impalapay.airtel.beans.geolocation.Country"%>
<%@page import="com.impalapay.airtel.accountmgmt.session.SessionStatistics"%>
<%@ page import="com.impalapay.airtel.accountmgmt.admin.SessionConstants"%>



<%@ page import="com.impalapay.airtel.cache.CacheVariables"%>

<%@ page import="org.apache.commons.lang.StringUtils" %>

<%@ page import="net.sf.ehcache.Cache" %>
<%@ page import="net.sf.ehcache.CacheManager" %>
<%@ page import="net.sf.ehcache.Element" %>

<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Calendar"%>
<%@ page import="java.util.Iterator"%>


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
    //End of session management code

   List<ManagementAccount> manageaccountList;

    //We assume Live and Developer AccountStatuses are equivalent.
   AccountStatusDAO accountStatusDAO = AccountStatusDAO.getInstance();
   List<AccountStatus> accountStatusList = accountStatusDAO.getAllAccountStatus();

    CacheManager mgr = CacheManager.getInstance();
    Cache accountsCache = mgr.getCache(CacheVariables.CACHE_MANAGEMENTACCOUNTS_BY_USERNAME);
    Cache statisticsCache = mgr.getCache(CacheVariables.CACHE_ALL_ACCOUNTS_STATISTICS);

    Element element;
    List keys = accountsCache.getKeys();

    int count = 0;  // A generic counter
    int incount = 0;  // Generic counter

    ManageAccountPaginator paginator = new ManageAccountPaginator();

    SessionStatistics statistics = new SessionStatistics();

     if ((element = statisticsCache.get(CacheVariables.CACHE_ALL_ACCOUNTS_STATISTICS_KEY)) != null) {
        statistics = (SessionStatistics) element.getObjectValue();
    }



    incount = statistics.getManagementAccountCountTotal();
    ManageAccountPage manageaccountPage;
    int manageaccountCount = 0; // The current count of the Accounts sessions

    if (incount == 0) { 	// This user has no Incoming USSD in the account
        manageaccountPage = new ManageAccountPage();
        manageaccountList = new ArrayList<ManagementAccount>();
        manageaccountCount = 0;

    } else {
        manageaccountPage = (ManageAccountPage) session.getAttribute("currentmanagementListPage");
        String referrer = request.getHeader("referer");
        String pageParam = (String) request.getParameter("page");

        // We are to give the first page
        if (manageaccountPage == null
                || !StringUtils.endsWith(referrer, "addManagementAccount.jsp")
                || StringUtils.equalsIgnoreCase(pageParam, "first")) {
            manageaccountPage = paginator.getFirstPage();

            // We are to give the last page
        } else if (StringUtils.equalsIgnoreCase(pageParam, "last")) {
            manageaccountPage = paginator.getLastPage();

            // We are to give the previous page
        } else if (StringUtils.equalsIgnoreCase(pageParam, "previous")) {
            manageaccountPage = paginator.getPrevPage(manageaccountPage);

            // We are to give the next page
        } else {
            manageaccountPage = paginator.getNextPage(manageaccountPage);
        }

        session.setAttribute("currentmanagementListPage", manageaccountPage);

        manageaccountList = manageaccountPage.getContents();

        manageaccountCount = (manageaccountPage.getPageNum() - 1) * manageaccountPage.getPagesize() + 1;


    }





%>
<html lang="en">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <!-- Meta, title, CSS, favicons, etc. -->
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>ImpalaPay | Networks</title>
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
                    <div class="page-title">
                        <div class="title_left">
                            <h3>Import members</h3>
                         </div>
                    </div>

                    <div class="row">
                        <div class="col-md-12">
                            <div class="x_panel">
                                <div class="x_content">ADMIN

                                    <div class="row">
                    <div class="box-content">
                        <%
                    String addErrStr = (String) session.getAttribute(SessionConstants.ADMIN_ADD_MANAGEMENTACCOUNT_ERROR_KEY);
                    String addSuccessStr = (String) session.getAttribute(SessionConstants.ADMIN_ADD_MANAGEMENTACCOUNT_SUCCESS_KEY);
                    HashMap<String, String> paramHash = (HashMap<String, String>) session.getAttribute(
                            SessionConstants.ADMIN_ADD_MANAGEMENTACCOUNT_PARAMETERS);

                    if (paramHash == null) {
                        paramHash = new HashMap<String, String>();
                    }

                    if (StringUtils.isNotEmpty(addErrStr)) {
                        out.println("<p class=\"alert alert-error\">");
                        out.println("Form error: " + addErrStr);
                        out.println("</p>");
                        session.setAttribute(SessionConstants.ADMIN_ADD_MANAGEMENTACCOUNT_ERROR_KEY, null);
                    }

                    if (StringUtils.isNotEmpty(addSuccessStr)) {
                        out.println("<p class=\"alert alert-success\">");
                        out.println(addSuccessStr);
                        out.println("</p>");
                        session.setAttribute(SessionConstants.ADMIN_ADD_MANAGEMENTACCOUNT_SUCCESS_KEY, null);
                    }
                %>


                        <form  class="form-horizontal form-label-left" action="addManageAccount" method="post">
                          <div class="form-group">
                                      <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">Permission group * <span class="required">*</span>
                                      </label>
                                  <div class="col-md-6 col-sm-6 col-xs-12">
                                   <select name="networkuuid" id="input" class="form-control col-md-3 col-xs-12">
                                     <option value="10">Disabled brokers</option>

                    			<option value="7">Disabled members</option>

                    			<option value="9">Full brokers</option>

                    			<option value="5">Full members</option>

                    			<option value="6">Inactive members</option></select>

                                   </select>
                                </div>  </div>

                                      <div class="form-group">
                                          <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">Account type * <span class="required">*</span>
                                          </label>
                                      <div class="col-md-6 col-sm-6 col-xs-12">
                                       <select name="networkuuid" id="input" class="form-control col-md-3 col-xs-12">
                                         <option value="">Choose..</option>


                                       </select>
                                    </div>  </div>

                                    <div class="form-group">
                                        <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">Payment type for positive balances * <span class="required">*</span>
                                        </label>
                                    <div class="col-md-6 col-sm-6 col-xs-12">
                                     <select name="networkuuid" id="input" class="form-control col-md-3 col-xs-12">
                                       <option value="">Choose..</option>


                                     </select>
                                  </div>  </div>

                                  <div class="form-group">
                                      <label class="control-label col-md-3 col-sm-3 col-xs-12" for="first-name">Payment type for negative balances * <span class="required">*</span>
                                      </label>
                                  <div class="col-md-6 col-sm-6 col-xs-12">
                                   <select name="networkuuid" id="input" class="form-control col-md-3 col-xs-12">
                                     <option value="">Choose..</option>


                                   </select>
                                </div>  </div>








                        <div class="box-footer">
                            <button type="submit" class="btn btn-primary" name="action">
                                <i class="icon-ok"></i>
                                Submit
                            </button>
                        </div>
                    </form>
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
