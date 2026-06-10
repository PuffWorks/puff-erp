const a={html:`<!DOCTYPE HTML>
<html>
<head>
<title>HTML Sample</title>
<meta charset="utf-8">
<style>
  h1 {
    font-family: Tahoma;
    font-size: 40px;
    font-weight: normal;
    margin: 50px;
    color: #a0a0a0;
  }

  button.Gray {
    font-family: Tahoma;
    font-size: 17px;
    font-weight: normal;
    margin-top: 100px;
    padding: 10px 50px;
    background-color: #727272;
    color: #fff;
    outline: 0;
    border: none;
    cursor: pointer;
  }

  button.Gray:hover {
    background-color: #898888;
  }
</style>
</head>
<body>
<!--This is the body section-->
<div class="Center">
  <h1>NAME OF SITE</h1>
</div>
<div>
  <button class="Gray" onclick="ButtonClick()">Click Me!</button>
</div>
<script>
  function ButtonClick(){
    // Example of comments in JavaScript
    window.alert("I'm an alert sample!");
  }
<\/script>
</body>
</html>
`,css:`html {
background-color: #e2e2e2;
margin: 0;
padding: 0;
}

body {
background-color: #fff;
border-top: solid 10px #000;
color: #333;
font-size: .85em;
font-family: "Segoe UI","HelveticaNeue-Light", sans-serif;
margin: 0;
padding: 0;
}

a:link, a:visited,
a:active, a:hover {
color: #333;
outline: none;
padding-left: 0;
padding-right: 3px;
text-decoration: none;
}

a:hover {
background-color: #c7d1d6;
}

h1, h2, h3,
h4, h5, h6 {
color: #000;
margin-bottom: 0;
padding-bottom: 0;
}
`,javascript:`/**
* 下载文件
* @param data 二进制数据
* @param name 文件名
* @param type 文件类型
*/
export function download(data, name, type) {
const blob = new Blob([data], { type: type || 'application/octet-stream' });
const url = window.URL.createObjectURL(blob);
const a = document.createElement('a');
a.href = url;
a.download = name;
a.style.display = 'none';
document.body.appendChild(a);
a.click();
document.body.removeChild(a);
URL.revokeObjectURL(url);
}

/**
* 深度克隆
* @param value 对象
*/
export function cloneDeep(value) {
const cache = new WeakMap();
const clone = (value) => {
  if (typeof value !== 'object' || value === null) {
    return value;
  }
  if (cache.has(value)) {
    return cache.get(value);
  }
  const result = Array.isArray(value) ? [] : {};
  cache.set(value, result);
  for (const key of Reflect.ownKeys(value)) {
    result[key] = clone(value[key]);
  }
  return result;
};
return clone(value);
}
`,typescript:`/**
* 下载文件
* @param data 二进制数据
* @param name 文件名
* @param type 文件类型
*/
export function download(
data: Blob | ArrayBuffer | string,
name: string,
type?: string
) {
const blob = new Blob([data], { type: type || 'application/octet-stream' });
const url = window.URL.createObjectURL(blob);
const a = document.createElement('a');
a.href = url;
a.download = name;
a.style.display = 'none';
document.body.appendChild(a);
a.click();
document.body.removeChild(a);
URL.revokeObjectURL(url);
}

/**
* 深度克隆
* @param value 对象
*/
export function cloneDeep(value?: any) {
const cache = new WeakMap();
const clone = (value?: any) => {
  if (typeof value !== 'object' || value == null) {
    return value;
  }
  if (cache.has(value)) {
    return cache.get(value);
  }
  const result = Array.isArray(value) ? [] : {};
  cache.set(value, result);
  for (const key of Reflect.ownKeys(value)) {
    result[key] = clone(value[key]);
  }
  return result;
};
return clone(value);
}
`,json:`{
"type": "team",
"test": {
  "testPage": "tools/testing/run-tests.htm",
  "enabled": true
},
"search": {
  "excludeFolders": [
    ".git",
    "node_modules",
    "tools/bin",
    "tools/counts",
    "tools/policheck",
    "tools/tfs_build_extensions",
    "tools/testing/jscoverage",
    "tools/testing/qunit",
    "tools/testing/chutzpah",
    "server.net"
  ]
}
}
`,scss:`$baseFontSizeInPixels: 14;

@function px2em ($font_size, $base_font_size: $baseFontSizeInPixels) {
@return ($font_size / $base_font_size) + em;
}

h1 {
font-size: px2em(36, $baseFontSizeInPixels);
}

h2  {
font-size: px2em(28, $baseFontSizeInPixels);
}

.class {
font-size: px2em(14, $baseFontSizeInPixels);
}

nav {
ul {
  margin: 0;
  padding: 0;
  list-style: none;
}

li { display: inline-block; }

a {
  display: block;
  padding: 6px 12px;
  text-decoration: none;
}

@each $animal in puma, sea-slug, egret, salamander {
  .#{$animal}-icon {
    background-image: url('/images/#{$animal}.png');
  }
}
}
`,less:`@base: #f938ab;

.box-shadow(@style, @c) when (iscolor(@c)) {
border-radius: @style @c;
}

.box-shadow(@style, @alpha: 50%) when (isnumber(@alpha)) {
.box-shadow(@style, rgba(0, 0, 0, @alpha));
}

.box {
color: saturate(@base, 5%);
border-color: lighten(@base, 30%);

div {
  .box-shadow((0 0 5px), 30%);
}
}

#header {
h1 {
  font-size: 26px;
  font-weight: bold;
}
}

@the-border: 1px;
@base-color: #111;
@red: #842210;

#header {
color: (@base-color * 3);
border-left: @the-border;
border-right: (@the-border * 2);
}

#footer {
color: (@base-color + #003300);
border-color: desaturate(@red, 10%);
}
`,handlebars:`<div class="entry">
<h1>{{title}}</h1>
{{#if author}}
<h2>{{author.firstName}} {{author.lastName}}</h2>
{{else}}
<h2>Unknown Author</h2>
{{/if}}
{{contentBody}}
</div>

{{#unless license}}
<h3 class="warning">WARNING: This entry does not have a license!</h3>
{{/unless}}

<div class="footnotes">
<ul>
  {{#each footnotes}}
  <li>{{this}}</li>
  {{/each}}
</ul>
</div>

<h1>Comments</h1>

<div id="comments">
{{#each comments}}
<h2><a href="/posts/{{../permalink}}#{{id}}">{{title}}</a></h2>
<div>{{body}}</div>
{{/each}}
</div>
`,razor:`@{
var total = 0;
var totalMessage = "";
@* a multiline
  razor comment embedded in csharp *@
if (IsPost) {
  // Retrieve the numbers that the user entered.
  var num1 = Request["text1"];
  var num2 = Request["text2"];

  // Convert the entered strings into integers numbers and add.
  total = num1.AsInt() + num2.AsInt();
  <italic><bold>totalMessage = "Total = " + total;</bold></italic>
}
}

<!DOCTYPE html>
<html lang="en">
<head>
  <title>Add Numbers</title>
  <meta charset="utf-8" />
</head>
<body>
<p>Enter two whole numbers and then click <strong>Add</strong>.</p>
<form action="" method="post">
  <p><label for="text1">First Number:</label>
    <input type="text" name="text1" />
  </p>
  <p><label for="text2">Second Number:</label>
    <input type="text" name="text2" />
  </p>
  <p><input type="submit" value="Add" /></p>
</form>

@* now we call the totalMessage method
   (a multi line razor comment outside code) *@

<p>@totalMessage</p>

<p>@(totalMessage+"!")</p>

An email address (with escaped at character): name@@domain.com

</body>
</html>
`,java:`import java.util.Random;

public class Example {
public static void main (String[] args){
  // Generate a random number between 1-100. (See generateRandomNumber method.)
  int random = generateRandomNumber(100);
  System.out.println("Generated number: " + random + "\\n");

  // Loop between 1 and the number we just generated.
  for (int i=1; i<=random; i++){
    if (i % 3 == 0 && i % 5 == 0){
      System.out.println("FizzBuzz");
    } else if (i % 3 == 0){
      System.out.println("Fizz");
    } else if (i % 5 == 0){
      System.out.println("Buzz");
    } else {
      System.out.println(i);
    }
  }
}

/**
 * Generates a new random number between 0 and 100.
 * @param bound The highest number that should be generated.
 * @return An integer representing a randomly generated number between 0 and 100.
 */
private static int generateRandomNumber(int bound){
  Random randGen = new Random();
  int randomNum = randGen.nextInt(bound);
  if (randomNum < 1){
    randomNum = generateRandomNumber(bound);
  }
  return randomNum;
}
}
`,c:`#pragma warning(disable : 4532)
#pragma warning(disable : 4702)

#if defined(_WIN32)

#if defined(_M_SH)
#define WIN_CE
#endif

#if defined(_M_AMD64)
#define NEST_IN_FINALLY /* allow when __try nested in __finally OK */
#endif

#define NTSTATUS LONG
#define EXCEPTION_NESTED_CALL 0x10
#define RtlRaiseStatus(x) RaiseException((x), 0, 0, NULL)
#define RtlRaiseException(x)                                                   \\
RaiseException((x)->ExceptionCode, (x)->ExceptionFlags,                      \\
               (x)->NumberParameters, (x)->ExceptionInformation)
#define IN
#define OUT
#if !(defined(_M_IA64) || defined(_M_ALPHA) || defined(_M_PPC) ||              \\
    defined(_M_AMD64) || defined(_M_ARM) || defined(_M_ARM64))
#define i386 1
#endif
#define try __try
#define except __except
#define finally __finally
#define leave __leave

#endif

#define WIN32_LEAN_AND_MEAN

#include "stdio.h"
#if defined(_M_IA64) || defined(_M_ALPHA) || defined(_M_PPC) ||                \\
  defined(_M_AMD64) || defined(_M_ARM) || defined(_M_ARM64)
#include "setjmpex.h"
#else
#include "setjmp.h"
#endif
#include "float.h"
#include "windows.h"
#include "math.h"

#if !defined(STATUS_SUCCESS)
#define STATUS_SUCCESS 0
#endif
#if !defined(STATUS_UNSUCCESSFUL)
#define STATUS_UNSUCCESSFUL ((NTSTATUS)0xC0000001L)
#endif
`,cpp:`#include "pch.h"
#include "Direct3DBase.h"

using namespace Microsoft::WRL;
using namespace Windows::UI::Core;
using namespace Windows::Foundation;

// Constructor.
Direct3DBase::Direct3DBase()
{
}

// Initialize the Direct3D resources required to run.
void Direct3DBase::Initialize(CoreWindow^ window)
{
  m_window = window;

  CreateDeviceResources();
  CreateWindowSizeDependentResources();
}

// These are the resources that depend on the device.
void Direct3DBase::CreateDeviceResources()
{
  // This flag adds support for surfaces with a different color channel ordering than the API default.
  // It is recommended usage, and is required for compatibility with Direct2D.
  UINT creationFlags = D3D11_CREATE_DEVICE_BGRA_SUPPORT;

#if defined(_DEBUG)
  // If the project is in a debug build, enable debugging via SDK Layers with this flag.
  creationFlags |= D3D11_CREATE_DEVICE_DEBUG;
#endif

  // This array defines the set of DirectX hardware feature levels this app will support.
  // Note the ordering should be preserved.
  // Don't forget to declare your application's minimum required feature level in its
  // description.  All applications are assumed to support 9.1 unless otherwise stated.
  D3D_FEATURE_LEVEL featureLevels[] =
  {
      D3D_FEATURE_LEVEL_11_1,
      D3D_FEATURE_LEVEL_11_0,
      D3D_FEATURE_LEVEL_10_1,
      D3D_FEATURE_LEVEL_10_0,
      D3D_FEATURE_LEVEL_9_3,
      D3D_FEATURE_LEVEL_9_2,
      D3D_FEATURE_LEVEL_9_1
  };

  // Create the DX11 API device object, and get a corresponding context.
  ComPtr<ID3D11Device> device;
  ComPtr<ID3D11DeviceContext> context;
  DX::ThrowIfFailed(
      D3D11CreateDevice(
          nullptr,                    // specify null to use the default adapter
          D3D_DRIVER_TYPE_HARDWARE,
          nullptr,                    // leave as nullptr unless software device
          creationFlags,              // optionally set debug and Direct2D compatibility flags
          featureLevels,              // list of feature levels this app can support
          ARRAYSIZE(featureLevels),   // number of entries in above list
          D3D11_SDK_VERSION,          // always set this to D3D11_SDK_VERSION
          &device,                    // returns the Direct3D device created
          &m_featureLevel,            // returns feature level of device created
          &context                    // returns the device immediate context
          )
      );

  // Get the DirectX11.1 device by QI off the DirectX11 one.
  DX::ThrowIfFailed(
      device.As(&m_d3dDevice)
      );

  // And get the corresponding device context in the same way.
  DX::ThrowIfFailed(
      context.As(&m_d3dContext)
      );
}
`,php:`<?php
// The next line contains a syntax error:
if () {
return "The parser recovers from this type of syntax error";
}
?>
<html>
<head>
<title>Example page</title>
</head>
<body>
<script type="text/javascript">
// Some PHP embedded inside JS
// Generated <?=date('l, F jS, Y')?>
var server_token = <?=rand(5, 10000)?>
if (typeof server_token === 'number') {
  alert('token: ' + server_token);
}
<\/script>
<div>
Hello
<? if (isset($user)) { ?>
<b><?=$user?></b>
<? } else { ?>
<i>guest</i>
<? } ?>
!
</div>
</body>
</html>
`,python:`import banana

class Monkey:
  # Bananas the monkey can eat.
  capacity = 10
  def eat(self, n):
      """Make the monkey eat n bananas!"""
      self.capacity -= n * banana.size

  def feeding_frenzy(self):
      self.eat(9.25)
      return "Yum yum"
`,go:`package main

import "strings"
import "fmt"

// Returns the first index of the target string \`t\`, or
// -1 if no match is found.
func Index(vs []string, t string) int {
  for i, v := range vs {
      if v == t {
          return i
      }
  }
  return -1
}

// Returns \`true\` if the target string t is in the
// slice.
func Include(vs []string, t string) bool {
  return Index(vs, t) >= 0
}

func main() {
  // Here we try out our various collection functions.
  var strs = []string{"peach", "apple", "pear", "plum"}
  fmt.Println(Index(strs, "pear"))
  fmt.Println(Include(strs, "grape"))
}
`,kotlin:`const val POINTS_X_PASS: Int = 15
val EZPassAccounts: MutableMap<Int, Int> = mutableMapOf(1 to 100, 2 to 100, 3 to 100)
val EZPassReport: Map<Int, Int> = EZPassAccounts

// update points credit
fun updatePointsCredit(accountId: Int) {
  if (EZPassAccounts.containsKey(accountId)) {
      println("Updating $accountId...")
      EZPassAccounts[accountId] = EZPassAccounts.getValue(accountId) + POINTS_X_PASS
  } else {
      println("Error: Trying to update a non-existing account (id: $accountId)")
  }
}

fun accountsReport() {
  println("EZ-Pass report:")
  EZPassReport.forEach{
      k, v -> println("ID $k: credit $v")
  }
}

fun main() {
  accountsReport()
  updatePointsCredit(1)
  updatePointsCredit(1)
  updatePointsCredit(5)
  accountsReport()
}
`,ruby:`module Azure
module Blob
  class Blob

    def initialize
      @properties = {}
      @metadata = {}
      yield self if block_given?
    end

    attr_accessor :name
    attr_accessor :snapshot
    attr_accessor :properties
    attr_accessor :metadata
  end
end
end
`,rust:`fn main() {
  let greetings = ["Hello", "Hola", "Bonjour",
                   "Ciao", "こんにちは", "안녕하세요",
                   "Cześć", "Olá", "Здравствуйте",
                   "Chào bạn", "您好", "Hallo",
                   "Hej", "Ahoj", "سلام"];

  for (num, greeting) in greetings.iter().enumerate() {
      print!("{} : ", greeting);
      match num {
          0 =>  println!("This code is editable and runnable!"),
          1 =>  println!("¡Este código es editable y ejecutable!"),
          2 =>  println!("Ce code est modifiable et exécutable !"),
          3 =>  println!("Questo codice è modificabile ed eseguibile!"),
          4 =>  println!("このコードは編集して実行出来ます！"),
          5 =>  println!("여기에서 코드를 수정하고 실행할 수 있습니다!"),
          6 =>  println!("Ten kod można edytować oraz uruchomić!"),
          7 =>  println!("Este código é editável e executável!"),
          8 =>  println!("Этот код можно отредактировать и запустить!"),
          9 =>  println!("Bạn có thể edit và run code trực tiếp!"),
          10 => println!("这段代码是可以编辑并且能够运行的！"),
          11 => println!("Dieser Code kann bearbeitet und ausgeführt werden!"),
          12 => println!("Den här koden kan redigeras och köras!"),
          13 => println!("Tento kód můžete upravit a spustit"),
          14 => println!("این کد قابلیت ویرایش و اجرا دارد!"),
          _ =>  {},
      }
  }
}
`,lua:`    -- defines a factorial function
  function fact (n)
    if n == 0 then
      return 1
    else
      return n * fact(n-1)
    end
  end

  print("enter a number:")
  a = io.read("*number")        -- read a number
  print(fact(a))
`,bat:`rem *******Begin Comment**************
rem This program starts the superapp batch program on the network,
rem directs the output to a file, and displays the file
rem in Notepad.
rem *******End Comment**************
@echo off
if exist C:output.txt goto EMPTYEXISTS
setlocal
path=g:programssuperapp;%path%
call superapp>C:output.txt
endlocal
:EMPTYEXISTS
start notepad c:output.txt
`,ini:`# Example of a .gitconfig file

[core]
repositoryformatversion = 0
filemode = false
bare = false
logallrefupdates = true
symlinks = false
ignorecase = true
hideDotFiles = dotGitOnly

# Defines the master branch
[branch "master"]
remote = origin
merge = refs/heads/master
`,shell:`#!/bin/bash

# Link filedescriptor 10 with stdin
exec 10<&0
# stdin replaced with a file supplied as a first argument
exec < $1
# remember the name of the input file
in=$1

# init
file="current_line.txt"
let count=0

# this while loop iterates over all lines of the file
while read LINE
do
  # increase line counter
  ((count++))
  # write current line to a tmp file with name $file (not needed for counting)
  echo $LINE > $file
  # this checks the return code of echo (not needed for writing; just for demo)
  if [ $? -ne 0 ]
   then echo "Error in writing to file \${file}; check its permissions!"
  fi
done

echo "Number of lines: $count"
echo "The last line of the file is: \`cat \${file}\`"

# Note: You can achieve the same by just using the tool wc like this
echo "Expected number of lines: \`wc -l $in\`"

# restore stdin from filedescriptor 10
# and close filedescriptor 10
exec 0<&10 10<&-
`,vb:`Imports System
Imports System.Collections.Generic

Module Module1

  Sub Main()
      Dim a As New M8Ball

      Do While True

          Dim q As String = ""
          Console.Write("ask me about the future... ")
          q = Console.ReadLine()

          If q.Trim <> "" Then
              Console.WriteLine("the answer is... {0}", a.getAnswer(q))
          Else
              Exit Do
          End If
      Loop

  End Sub

End Module

Class M8Ball

  Public Answers As System.Collections.Generic.Dictionary(Of Integer, String)

  Public Sub New()
      Answers = New System.Collections.Generic.Dictionary(Of Integer, String)
      Answers.Add(0, "It is certain")
      Answers.Add(1, "It is decidedly so")
      Answers.Add(2, "Without a doubt")
      Answers.Add(3, "Yes, definitely")
      Answers.Add(4, "You may rely on ")
      Answers.Add(5, "As I see it, yes")
      Answers.Add(6, "Most likely")
      Answers.Add(7, "Outlook good")
      Answers.Add(8, "Signs point to yes")
      Answers.Add(9, "Yes")
      Answers.Add(10, "Reply hazy, try again")
      Answers.Add(11, "Ask again later")
      Answers.Add(12, "Better not tell you now")
      Answers.Add(13, "Cannot predict now")
      Answers.Add(14, "Concentrate and ask again")
      Answers.Add(15, "Don't count on it")
      Answers.Add(16, "My reply is no")
      Answers.Add(17, "My sources say no")
      Answers.Add(18, "Outlook not so")
      Answers.Add(19, "Very doubtful")
  End Sub

  Public Function getAnswer(theQuestion As String) As String
      Dim r As New Random
      Return Answers(r.Next(0, 19))
  End Function

End Class
`,yaml:`%TAG ! tag:clarkevans.com,2002:
--- !shape
# Use the ! handle for presenting
# tag:clarkevans.com,2002:circle
- !circle
center: &ORIGIN {x: 73, y: 129}
radius: 7
- !line
start: *ORIGIN
finish: { x: 89, y: 102 }
- !label
start: *ORIGIN
color: 0xFFEEBB
text: Pretty vector drawing.
`,xml:`<?xml version="1.0"?>
<configuration xmlns:xdt="http://schemas.microsoft.com/XML-Document-Transform">
<connectionStrings>
  <add name="MyDB"
    connectionString="value for the deployed Web.config file"
    xdt:Transform="SetAttributes" xdt:Locator="Match(name)"/>
</connectionStrings>
<system.web>
  <customErrors defaultRedirect="GenericError.htm"
    mode="RemoteOnly" xdt:Transform="Replace">
    <error statusCode="500" redirect="InternalError.htm"/>
  </customErrors>
</system.web>
</configuration>
`,mysql:`CREATE TABLE shop (
  article INT(4) UNSIGNED ZEROFILL DEFAULT '0000' NOT NULL,
  dealer  CHAR(20)                 DEFAULT ''     NOT NULL,
  price   DOUBLE(16,2)             DEFAULT '0.00' NOT NULL,
  PRIMARY KEY(article, dealer));
INSERT INTO shop VALUES
  (1,'A',3.45),(1,'B',3.99),(2,'A',10.99),(3,'B',1.45),
  (3,'C',1.69),(3,'D',1.25),(4,'D',19.95);
`,dockerfile:`FROM mono:3.12

ENV KRE_FEED https://www.myget.org/F/aspnetvnext/api/v2
ENV KRE_USER_HOME /opt/kre

RUN apt-get -qq update && apt-get -qqy install unzip

ONBUILD RUN curl -sSL https://raw.githubusercontent.com/aspnet/Home/dev/kvminstall.sh | sh
ONBUILD RUN bash -c "source $KRE_USER_HOME/kvm/kvm.sh \\
  && kvm install latest -a default \\
  && kvm alias default | xargs -i ln -s $KRE_USER_HOME/packages/{} $KRE_USER_HOME/packages/default"

# Install libuv for Kestrel from source code (binary is not in wheezy and one in jessie is still too old)
RUN apt-get -qqy install \\
  autoconf \\
  automake \\
  build-essential \\
  libtool
RUN LIBUV_VERSION=1.0.0-rc2 \\
  && curl -sSL https://github.com/joyent/libuv/archive/v\${LIBUV_VERSION}.tar.gz | tar zxfv - -C /usr/local/src \\
  && cd /usr/local/src/libuv-$LIBUV_VERSION \\
  && sh autogen.sh && ./configure && make && make install \\
  && rm -rf /usr/local/src/libuv-$LIBUV_VERSION \\
  && ldconfig

ENV PATH $PATH:$KRE_USER_HOME/packages/default/bin

# Extra things to test
RUN echo "string at end"
RUN echo must work 'some str' and some more
RUN echo hi this is # not a comment
RUN echo 'String with \${VAR} and another $one here'
`};function r(e,t,n){return`<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>代码运行 - Ele Admin Plus</title>
    <style>
      ${e}
    </style>
    <script>
      !(function () {
        const originalConsoleMethods = {
  log: console.log,
  error: console.error,
  warn: console.warn
};
['log', 'error', 'warn'].forEach(function(methodName) {
  console[methodName] = function () {
    originalConsoleMethods[methodName].apply(console, arguments);
    parent.postMessage({ id: 'iframeConsole', code: [...arguments].flat().join(' '), type: methodName }, '*');
  };
});
window.onerror = function(message, source, lineno, colno, error) {
  const errorStack = \`\${message}
at (\${source}:\${lineno}:\${colno})\`;
  parent.postMessage({ id: 'iframeConsole', code: error.stack || errorStack, type: 'error' }, '*');
};

      })();
    <\/script>
  </head>
  <body>
    ${t}
    <script>
      !(function () {
        ${n}
      })();
    <\/script>
  </body>
</html>
`}export{a as c,r as g};
