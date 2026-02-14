public static class ConnectionStringBuilder
{
    private const string ENV_VARIABLE = "__MY_SQL_LOCAL_PASSWORD";

    public static string GetConnectionString(string connString)
    {
        if (connString?.Contains(ENV_VARIABLE) == true)
        {
            var realPassword = Environment.GetEnvironmentVariable(ENV_VARIABLE);
            if (string.IsNullOrEmpty(realPassword))
            {
                throw new InvalidOperationException(String.Format("{0} environment variable is missing.", ENV_VARIABLE));
            }

            connString = connString.Replace(String.Format("${{{{{0}}}}}", ENV_VARIABLE), realPassword);
        }

        return connString;
    }
}
