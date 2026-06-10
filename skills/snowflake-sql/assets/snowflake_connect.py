#!/usr/bin/env python3
"""
Snowflake Connection Helper for NBA
Connects to Snowflake using SSO authentication
"""

import snowflake.connector
from snowflake.connector import DictCursor
import sys

def connect_to_snowflake(
    account='NBA-DATA',  # NBA Snowflake account from connections.toml
    user=None,  # Your NBA SSO email — set via SNOWFLAKE_USER env var or pass directly
    warehouse='YOUR_WAREHOUSE',  # Set to your Snowflake warehouse (e.g. VWH_DSA_DEV)
    database=None,
    schema=None,
    role='YOUR_SNOWFLAKE_ROLE'  # Set to your Snowflake role (e.g. FR_ANALYST, SYSADMIN)
):
    """
    Connect to NBA Snowflake using SSO authentication.

    Args:
        account: Snowflake account identifier
        user: User email (optional, SSO will handle)
        warehouse: Default warehouse to use
        database: Default database to use
        schema: Default schema to use
        role: Snowflake role to assume

    Returns:
        snowflake.connector.Connection object
    """

    connection_params = {
        'account': account,
        'authenticator': 'externalbrowser',  # SSO via browser
        'warehouse': warehouse,
        'role': role
    }

    if user:
        connection_params['user'] = user
    if database:
        connection_params['database'] = database
    if schema:
        connection_params['schema'] = schema

    print(f"Connecting to Snowflake account: {account}")
    print(f"Role: {role}")
    print(f"Warehouse: {warehouse}")
    print("\nOpening browser for SSO authentication...")

    try:
        conn = snowflake.connector.connect(**connection_params)
        print("✅ Successfully connected to Snowflake!")

        # Display connection info
        cursor = conn.cursor()
        cursor.execute("SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_WAREHOUSE(), CURRENT_DATABASE()")
        result = cursor.fetchone()
        print(f"\nConnection Details:")
        print(f"  User: {result[0]}")
        print(f"  Role: {result[1]}")
        print(f"  Warehouse: {result[2]}")
        print(f"  Database: {result[3]}")
        cursor.close()

        return conn

    except Exception as e:
        print(f"❌ Connection failed: {str(e)}", file=sys.stderr)
        raise


def run_query(conn, query, fetch_all=True):
    """
    Execute a query and return results.

    Args:
        conn: Snowflake connection object
        query: SQL query string
        fetch_all: If True, return all rows. If False, return cursor for iteration.

    Returns:
        List of dictionaries (if fetch_all=True) or cursor object
    """
    cursor = conn.cursor(DictCursor)
    cursor.execute(query)

    if fetch_all:
        results = cursor.fetchall()
        cursor.close()
        return results
    else:
        return cursor


def close_connection(conn):
    """Close Snowflake connection."""
    if conn:
        conn.close()
        print("🔒 Connection closed")


if __name__ == "__main__":
    # Example usage: connect and run a test query
    try:
        # Connect
        conn = connect_to_snowflake()

        # Test query - show databases you have access to
        print("\n" + "="*50)
        print("Databases accessible with your role:")
        print("="*50)

        results = run_query(conn, "SHOW DATABASES")
        for row in results:
            print(f"  - {row['name']}")

        # Show warehouses
        print("\n" + "="*50)
        print("Warehouses accessible:")
        print("="*50)

        results = run_query(conn, "SHOW WAREHOUSES")
        for row in results:
            print(f"  - {row['name']} (Size: {row['size']}, State: {row['state']})")

        # Close
        close_connection(conn)

    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)
