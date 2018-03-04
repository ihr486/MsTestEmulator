#pragma once

#include <iostream>
#include <stdlib.h>

#define TEST_METHOD_ATTR __attribute__((used,section(".testmethod")))
#define TEST_METHOD_INIT_ATTR __attribute__((used,section(".testmethodinit")))

#define TEST_CLASS(class_name) struct class_name
#define TEST_METHOD(method_name) static void TEST_METHOD_ATTR method_name
#define TEST_METHOD_INITIALIZE(method_name) static void TEST_METHOD_INIT_ATTR method_name

namespace Microsoft
{
namespace VisualStudio
{
namespace CppUnitTestFramework
{
class Logger
{
public:
    static void WriteMessage(const char *msg)
    {
        std::cout << msg;
    }
    static void WriteMessage(const wchar_t *msg)
    {
        std::wcout << msg;
    }
};
class Assert
{
public:
    template<typename T>
    static void AreEqual(const T& expected, const T& actual, const wchar_t *message = NULL)
    {
        if (!(expected == actual))
        {
            std::wcerr << L"Assert failed. Expected:" << ToString(expected) << L" Actual:" << ToString(actual) << std::endl;
            if (message != NULL)
                std::wcerr << message << std::endl;
            exit(EXIT_FAILURE);
        }
    }
    template<typename T>
    static void AreNotEqual(const T& expected, const T& actual, const wchar_t *message = NULL)
    {
        if (expected == actual)
        {
            std::wcerr << L"Assert failed. Expected:" << ToString(expected) << L" Actual:" << ToString(actual) << std::endl;
            if (message != NULL)
                std::wcerr << message << std::endl;
            exit(EXIT_FAILURE);
        }
    }
    static void IsTrue(bool expr, const wchar_t *message = NULL)
    {
        if (!expr)
        {
            std::wcerr << L"Assert failed." << std::endl;
            if (message != NULL)
                std::wcerr << message << std::endl;
            exit(EXIT_FAILURE);
        }
    }
    static void IsFalse(bool expr, const wchar_t *message = NULL)
    {
        if (expr)
        {
            std::wcerr << L"Assert failed." << std::endl;
            exit(EXIT_FAILURE);
        }
    }
    static void Fail(const wchar_t *message = NULL)
    {
        std::wcerr << L"Assert failed." << std::endl;
        exit(EXIT_FAILURE);
    }
};
}
}
}
