package com.impalapay.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.reflect.TypeToken;
import com.impalapay.dao.AccountsDao;
import com.impalapay.model.Accounts;


public class AccountsController extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private AccountsDao dao;
    
    public AccountsController() {
        dao=new AccountsDao();
    }


	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
	}

	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		if(request.getParameter("action")!=null){
			List<Accounts> lstAccounts=new ArrayList<Accounts>();
			String action=(String)request.getParameter("action");
			Gson gson = new Gson();
			response.setContentType("application/json");
			
			if(action.equals("list")){
				try{						
				//Fetch Data from User Table
				lstAccounts=dao.getAllUsers();			
				//Convert Java Object to Json				
				JsonElement element = gson.toJsonTree(lstAccounts, new TypeToken<List<Accounts>>() {}.getType());
				JsonArray jsonArray = element.getAsJsonArray();
				String listData=jsonArray.toString();				
				//Return Json in the format required by jTable plugin
				listData="{\"Result\":\"OK\",\"Records\":"+listData+"}";			
				response.getWriter().print(listData);
				}catch(Exception ex){
					String error="{\"Result\":\"ERROR\",\"Message\":"+ex.getMessage()+"}";
					response.getWriter().print(error);
					ex.printStackTrace();
				}				
			}
			else if(action.equals("create") || action.equals("update")){
				Accounts accounts=new Accounts();
				if(request.getParameter("userid")!=null){				   
				   int userid=Integer.parseInt(request.getParameter("userid"));
				   accounts.setUserid(userid);
				}
				if(request.getParameter("firstName")!=null){
					String firstname=(String)request.getParameter("firstName");
					accounts.setFirstName(firstname);
				}
				if(request.getParameter("lastName")!=null){
				   String lastname=(String)request.getParameter("lastName");
				   accounts.setLastName(lastname);
				}
				if(request.getParameter("email")!=null){
				   String email=(String)request.getParameter("email");
				   accounts.setEmail(email);
				}
				try{											
					if(action.equals("create")){//Create new record
						//dao.addUser(user);	
						dao.addAccounts(accounts);
						lstAccounts.add(accounts);
						//Convert Java Object to Json				
						String json=gson.toJson(accounts);					
						//Return Json in the format required by jTable plugin
						String listData="{\"Result\":\"OK\",\"Record\":"+json+"}";											
						response.getWriter().print(listData);
					}else if(action.equals("update")){//Update existing record
						dao.updateUser(accounts);
						String listData="{\"Result\":\"OK\"}";									
						response.getWriter().print(listData);
					}
				}catch(Exception ex){
						String error="{\"Result\":\"ERROR\",\"Message\":"+ex.getStackTrace().toString()+"}";
						response.getWriter().print(error);
				}
			}else if(action.equals("delete")){//Delete record
				try{
					if(request.getParameter("userid")!=null){
						String userid=(String)request.getParameter("userid");
						dao.deleteUser(Integer.parseInt(userid));
						String listData="{\"Result\":\"OK\"}";								
						response.getWriter().print(listData);
					}
				}catch(Exception ex){
				String error="{\"Result\":\"ERROR\",\"Message\":"+ex.getStackTrace().toString()+"}";
				response.getWriter().print(error);
			}				
		}
	 }
  }
}
