using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using CustomManager.DatabaseLoadApp.Models;

namespace CustomManager.DatabaseLoadApp
{
    class Program
    {
        const string LoremIpsum = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";


        static void Main(string[] args)
        {

            Console.WriteLine("Creating new records in Foo table...");
            Console.WriteLine("Press any key to Exit");

            string longstring = String.Join(Environment.NewLine, Enumerable.Repeat(LoremIpsum, 30));

            using (var cancelationSource = new CancellationTokenSource())
            {
                var cancelationToken = cancelationSource.Token;
    
                var action = (Action)(() =>
                {
                    var sw = new Stopwatch();
                    
                    var rand = new Random((int)DateTime.UtcNow.Ticks);
                    var repository = new FooRepository();
                    int counter = 0;
                    long elapsedSeconds;
                    long lastPrintedSeconds = 0;
                    sw.Start();
                    while (true)
                    {

                       
                        var model = new Foo
                        {
                            LongText1 = longstring.Substring(0, rand.Next(100, 255)),
                            LongText2 = longstring.Substring(0, rand.Next(2000, 4000)),

                        };
                        try
                        {
                            repository.Add(model);

                            Console.WriteLine("[Thread: {2:d2}] INS: Id: {0:D10} - {1:D10}", model.Id,
                                sw.ElapsedMilliseconds / 1000, Thread.CurrentThread.ManagedThreadId);


                            model.LongText1 = longstring.Substring(0, rand.Next(50, 255));
                            model.LongText2 = longstring.Substring(0, rand.Next(3000, 4000));

                            repository.Update(model);
                            Console.WriteLine("[Thread: {2:d2}] UPD: Id: {0:D10} - {1:D10}", model.Id,
                                sw.ElapsedMilliseconds / 1000, Thread.CurrentThread.ManagedThreadId);



                            repository.Get(model.Id);
                            Console.WriteLine("[Thread: {2:d2}] SEL: Id: {0:D10} - {1:D10}", model.Id,
                                sw.ElapsedMilliseconds / 1000, Thread.CurrentThread.ManagedThreadId);

                        }
                        catch (Exception ex)
                        {
                            Console.ForegroundColor = ConsoleColor.Red;
                            Console.WriteLine("[Thread: {2:d2}] Exception: {0:D10}: {1}",
                                sw.ElapsedMilliseconds/1000, ex.Message, Thread.CurrentThread.ManagedThreadId);
                            Console.ResetColor();
;                        }
                        cancelationToken.ThrowIfCancellationRequested();


                        counter += 3;
                        elapsedSeconds = sw.ElapsedMilliseconds/1000;

                        if (elapsedSeconds > lastPrintedSeconds)
                        {
                            Console.ForegroundColor = ConsoleColor.Cyan;
                            Console.WriteLine("[Thread: {1:D2}] Transactions in second: {0:N1}",
                                (double)(counter / (elapsedSeconds - lastPrintedSeconds)), Thread.CurrentThread.ManagedThreadId);
                            Console.ResetColor();

                            lastPrintedSeconds = elapsedSeconds;
                            counter = 0;
                        }

                    }


                });


                Task.Factory.StartNew(action, cancelationToken);
                Task.Factory.StartNew(action, cancelationToken);


                Console.Read();
                cancelationSource.Cancel();

            }

        }
    }
}
