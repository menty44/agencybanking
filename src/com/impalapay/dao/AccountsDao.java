package com.impalapay.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;

import com.impalapay.model.Accounts;
import com.impalapay.utility.DBUtility;

public class AccountsDao {
	
	private Connection connection;

	public AccountsDao() {
		connection = DBUtility.getConnection();
	}

	public void addAccounts(Accounts accounts) {
		try {
			
			PreparedStatement preparedStatement = connection
					.prepareStatement("insert into tblUser(userid,firstname,lastname,email) values (?,?, ?, ? )");
			// Parameters start with 1
			preparedStatement.setInt(1, accounts.getUserid());
			preparedStatement.setString(2, accounts.getFirstName());
			preparedStatement.setString(3, accounts.getLastName());			
			preparedStatement.setString(4, accounts.getEmail());
			preparedStatement.executeUpdate();

		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public void deleteUser(int userId) {
		try {
			PreparedStatement preparedStatement = connection
					.prepareStatement("delete from tblUser where userid=?");
			// Parameters start with 1
			preparedStatement.setInt(1, userId);
			preparedStatement.executeUpdate();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public void updateUser(Accounts accounts) throws ParseException {
		try {
			PreparedStatement preparedStatement = connection
					.prepareStatement("update tblUser set lastname=?,email=?" +
							"where userid=?");
			// Parameters start with 1			
			preparedStatement.setString(1, accounts.getLastName());
			preparedStatement.setString(2, accounts.getEmail());			
			preparedStatement.setInt(3, accounts.getUserid());
			preparedStatement.executeUpdate();

		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public List<Accounts> getAllUsers() {
		List<Accounts> accounts = new ArrayList<Accounts>();
		try {
			Statement statement = connection.createStatement();
			ResultSet rs = statement.executeQuery("select * from tblUser");
			while (rs.next()) {
				Accounts account = new Accounts();
				account.setUserid(rs.getInt("userid"));
				account.setFirstName(rs.getString("firstname"));
				account.setLastName(rs.getString("lastname"));				
				account.setEmail(rs.getString("email"));
				accounts.add(account);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return accounts;
	}
	
	public Accounts getUserById(int userId) {
		Accounts accounts = new Accounts();
		try {
			PreparedStatement preparedStatement = connection.
					prepareStatement("select * from tblUser where userid=?");
			preparedStatement.setInt(1, userId);
			ResultSet rs = preparedStatement.executeQuery();
			
			if (rs.next()) {
				accounts.setUserid(rs.getInt("userid"));
				accounts.setFirstName(rs.getString("firstname"));
				accounts.setLastName(rs.getString("lastname"));
				
				accounts.setEmail(rs.getString("email"));
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return accounts;
	}

}
