﻿namespace core.exceptions
{
    public class NonInitializeException : System.Exception
    {
        public NonInitializeException(string message = "The object is not initialized...") : base(message)
        {

        }
    }
}
