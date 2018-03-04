/*!
 * @brief Drop-in replacement for CppUnitTest.h included in the Microsoft C++ Unit Test Framework.
 */
#pragma once

#include <iostream>
#include <string>
#include <codecvt>
#include <locale>
#include <stdlib.h>
#include <string.h>
#include <wchar.h>

#define TEST_METHOD_ATTR __attribute__((used,section(".testmethod")))
#define TEST_METHOD_INIT_ATTR __attribute__((used,section(".testmethodinit")))

#define TEST_CLASS(class_name) struct class_name
#define TEST_METHOD(method_name) static void TEST_METHOD_ATTR method_name()
#define TEST_METHOD_INITIALIZE(method_name) static void TEST_METHOD_INIT_ATTR method_name()

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
template<typename T>
static std::wstring ToString(const T& obj);
class Assert
{
    template<typename T>
    static bool Equals(const T& a, const T& b)
    {
        return a == b;
    }
    static bool Equals(const char *a, const char *b)
    {
        return !strcmp(a, b);
    }
    static bool Equals(const wchar_t *a, const wchar_t *b)
    {
        return !wcscmp(a, b);
    }
    template<typename T>
    static std::wstring ToString(T val)
    {
        return std::to_wstring(val);
    }
    static std::wstring ToString(const char *str)
    {
        std::wstring_convert<std::codecvt_utf8<wchar_t>,wchar_t> cvt;
        return cvt.from_bytes(str);
    }
    static std::wstring ToString(const wchar_t *str)
    {
        return std::wstring(str);
    }
public:
    template<typename T>
    static void AreEqual(const T& expected, const T& actual, const wchar_t *message = NULL)
    {
        if (!Equals(expected, actual))
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
        if (Equals(expected, actual))
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
