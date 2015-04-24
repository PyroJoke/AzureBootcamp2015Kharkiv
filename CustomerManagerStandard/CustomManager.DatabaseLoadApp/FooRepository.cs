using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using CustomManager.DatabaseLoadApp.Models;
using Dapper;

namespace CustomManager.DatabaseLoadApp
{
    public class FooRepository
    {
        public IDbConnection OpenConnection()
        {
            return new SqlConnection(ConfigurationManager.ConnectionStrings["azure"].ConnectionString);
        }


        public void Add(Foo model)
        {
            using (var connection = OpenConnection())
            {

                const string sql = @"
                INSERT INTO dbo.Foo(LongText1, LongText2) VALUES(@LongText1, @LongText2);
                SELECT CAST(SCOPE_IDENTITY() as BIGINT)";

                model.Id = connection.Query<long>(sql, model).Single();
            }
            
        }


        public void Update(Foo model)
        {
         
            using (var connection = OpenConnection())
            {

                const string sql = @"
                UPDATE dbo.Foo SET LongText1 = @LongText1, LongText2 = @LongText2
                WHERE Id = @Id;";

               connection.Execute(sql, model);
            }
            
        
        }

        public void Get(long id)
        {

            using (var connection = OpenConnection())
            {

                const string sql = @"
                SELECT Id, LongText1, LongText2 FROM dbo.Foo WHERE Id = @Id";

                connection.Query<Foo>(sql, new {Id = id});
            }


        }




    }
}
