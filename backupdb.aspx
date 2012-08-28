<%@ Page Language="C#" %>

<%@ Import Namespace="System" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Rackspace.Cloudfiles" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        // Please Enter Your CloudFiles Information Below
        
        string username = "YourCloudFilesUserName";
        string api_access_key = "YourCloudFilesApiKey";
        string containerName = "zipit-backups-databases";
        bool snet = false;

        // Please Enter Your MSSQL Database Information Below

        string hnametxt = "YourDatabaseHostName";
        string dbnametxt = "YourDatabaseName";
        string usernamedbtxt = "YourDatabaseUserName";
        string pwordtxt = "YourPassword";
        string connectionstring = "Data Source=" + hnametxt + ";Initial Catalog=" + dbnametxt + ";User ID=" + usernamedbtxt + ";Password=" + pwordtxt;

        string timestamp = DateTime.Now.ToString("MM-dd-yyyy_HH-mm-ss");
        string path = Server.MapPath(".") + "\\";
        string FileName = "dbBackup-" + timestamp + ".bak";
        string absolutepath = path + FileName;

        try
        {
            var userCredentials = new UserCredentials(username, api_access_key);
            var client = new CF_Client();
            Connection conn = new CF_Connection(userCredentials, client);
            conn.Authenticate(snet);

            var account = new CF_Account(conn, client);
            account.CreateContainer(containerName);

            if (File.Exists(path + FileName))
            {
                SqlConnection sqlConn = new SqlConnection(connectionstring);
                SqlCommand sqlComm = new SqlCommand();
                sqlComm = sqlConn.CreateCommand();
                sqlComm.CommandText = @"DECLARE @RC int EXECUTE @RC = [dbo].[FullBackup] @FileName";
                sqlConn.Open();
                sqlComm.Parameters.AddWithValue("@FileName", absolutepath);


                sqlComm.ExecuteNonQuery();
                sqlConn.Close();


                var container = new CF_Container(conn, client, containerName);
                var obj = new CF_Object(conn, container, client, FileName);

                obj.WriteFromFile(path + "\\" + FileName);

                FileInfo fi = new FileInfo(path + "\\" + FileName);

                var containeritems = container.GetObjects(true);


                fi.Delete();

                lblInfo.Text = "Database Backup Completed Successfully";

            }
            else if (!File.Exists(path + FileName))
            {
                SqlConnection sqlConn = new SqlConnection(connectionstring);
                SqlCommand sqlComm = new SqlCommand();
                sqlComm = sqlConn.CreateCommand();
                sqlComm.CommandText = @"DECLARE @RC int EXECUTE @RC = [dbo].[FullBackup] @FileName";
                sqlConn.Open();
                sqlComm.Parameters.AddWithValue("@FileName", absolutepath);
                sqlComm.ExecuteNonQuery();
                sqlConn.Close();
                
                var container = new CF_Container(conn, client, containerName);
                var obj = new CF_Object(conn, container, client, FileName);
                
                obj.WriteFromFile(path + "\\" + FileName);

                FileInfo fi = new FileInfo(path + "\\" + FileName);

                var containeritems = container.GetObjects(true);
                
                fi.Delete();
                
                lblInfo.Text = "Database Backup Completed Successfully";
            }
            else
            {
                lblInfo.Text = "Something has gone wrong!";
            }
        }
        catch (Exception ex)
        {
            lblInfo.Text = "The process failed:" + ex.ToString();
        }

    }
    
</script>

<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:Label runat="server" ID="lblInfo" ForeColor="Red" Text="" />
        </div>
    </form>
</body>
</html>
