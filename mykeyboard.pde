import java.net.URLEncoder;
import java.io.*;
import processing.net.*;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

String baseURL = "http://www.google.com/transliterate?langpair=ja-Hira|ja&text=";
String[] kekka = {""};//予測例示のリスト
JSONArray values;
float width = 100 - 6;
float height = 60 - 4;
String str = "";//出力の文字列
String trans_str = "";//変換対象の文字列
String recent_str ="";//直近で打った文字
PImage img1;//バックスペースの写真
PImage img2;//濁点、半濁点、小文字の写真
JSONArray  jarray;

class Key{//Keyのクラス
  String name;
  float centerX;
  float centerY;
  int pressedX;
  int pressedY;
  int pressedflag = 0;
  int center_flag = 0;
  
  Key(String name, float centerX, float centerY){
    this.name = name;
    this.centerX = centerX;
    this.centerY = centerY;
  }
  
  void keydraw1(){
    stroke(0,0,0);
    if(pressedflag == 1 && center_flag ==1){
     fill(200);
     rect(centerX - width/2, centerY - height/2, width, height, 10, 10, 10, 10);
    } else {
    fill(255,255,255);
    rect(centerX  - width/2, centerY - height/2, width, height, 10, 10, 10, 10);
    }
  }
  
  void keydraw2(){
  }
  
  void keydraw3(){//キー上の絵や文字の表示
    fill(0);
    textSize(20);
    if (name == "バックスペース"){
      image(img1, centerX-15, centerY-15, 30, 30);
    }else if (name == "変換"){
      image(img2,  centerX-35, centerY-25, 70, 50);
    }else if (name == "空白"){
      text("空白",centerX, centerY);
    }else if (name == "右"){
      text("→",centerX, centerY);
    }else if (name == "回転"){
      text("↺",centerX, centerY);
    }else if (name == "改行"){
      text("改行",centerX, centerY);
    }else {
      text(name,centerX, centerY);
    fill(255,255,255);
    } 
  }

  void released(){//キーを離した時の処理
    pressedflag = 0;
    if (center_flag == 1){
      if(name == "バックスペース"){//バックスペースの処理
        if( str.length() >0){
          str = str.substring(0, str.length()-1);
        }
        if(trans_str.length() >0){
          trans_str =  trans_str.substring(0, trans_str.length()-1);
         }
        recent_str = "";
      }else if(name == "空白"){//空白の処理
        str = str + "　";
        trans_str = "";
      }else if(name == "改行"){//改行の処理
        str = str + "\n";
        trans_str = "";
      }else if(name == "変換"){//変換の処理
        trans(recent_str);
      }else if(name == "a/A"){//アルファベット大⇔小の処理
        if (Character.isLowerCase(recent_str.toCharArray()[0]) ){
          recent_str = recent_str.toUpperCase();
        } else if (Character.isUpperCase(recent_str.toCharArray()[0]) ){
          recent_str = recent_str.toLowerCase();
        }
        str = str.substring(0, str.length()-1);
        str = str + recent_str;
      }else if(name == "ABC"){//アルファベットに遷移する処理
        modechange(1);
      }else if(name == "確定"){//確定の処理
        trans_str = "";
      }else if(name == "☆123"){//123に遷移する処理
        modechange(2);
      }else if(name == "あいう"){//あいうに遷移する処理
        modechange(0);
      }
      center_flag = 0;
      String text  =URLEncode(trans_str);
      JSONArray values = loadJSONArray(baseURL + text);
      if(values == null){
        for(int i=0; i<kekka.length;i++){
          kekka[i]= "";
        }
      }else{
        JSONArray abc = values.getJSONArray(0);
        JSONArray abclist = abc.getJSONArray(1);
        kekka = abclist.getStringArray();
      }
    }
  }
  
  void pressed(int x, int y ){
    if(x<= centerX + width/2  && x >= centerX - width/2  && y >= centerY - height/2 && y<= centerY + height/2){
      pressedflag = 1;
      pressedX = x;
      pressedY = y;
      center_flag = 1;
      fill(200);
      rect(centerX - width/2, centerY - height/2, width, height, 10, 10, 10, 10);
    }
  }
  
  void dragged(int x, int y){
  }
}

class FlickKey extends Key{
  int flick_mode= 0;
  int swipe_mode= 0;
  int flick_flag = 0;
  int right_flag = 0;
  int left_flag = 0;
  int up_flag = 0;
  int down_flag = 0;
  double pressed_time = 100000000;
  double released_time = 0;
  String[] keylist;
  
  FlickKey(String name, float centerX, float centerY , String[] keylist){
    super(name, centerX, centerY);
    this.keylist = keylist;
  }
  
  void keydraw1(){
    stroke(0,0,0);
    fill(255,255,255);
    rect(centerX  - width/2, centerY - height/2, width, height, 10, 10, 10, 10);
    double time = millis();//時間をはかる
    if (time - pressed_time <= 400 || flick_flag ==1){//フリックモードの処理
      flick_mode = 1;
      swipe_mode = 0;
    }else if(time - pressed_time > 400 && center_flag == 1 ){//スワイプモードの処理
      flick_mode = 0;
      swipe_mode = 1;
    }
  }
  
  void keydraw2(){//keydrawと一緒にしてしまうと、おかしくなるので分ける
    stroke(0,0,0);
    fill(255,255,255);
    if (flick_flag == 1){//フリック処理の記述
      if(right_flag == 1){//対象キーの右にあるなら
        fill(200);
        rect(centerX  - width/2, centerY - height/2, width, height, 10, 10, 10, 10);
        fill(230);
        stroke(230); 
        rect(centerX +width/2, centerY - height/2, width, height, 0, 10, 10,0);
        triangle(centerX, centerY, centerX +width/2, centerY - height/2, centerX +width/2, centerY + height/2);
        fill(0);
        textSize(20);
        text(keylist[3],centerX+width, centerY);
        fill(255);  
      }
      if(left_flag == 1){//対象キーの左にあるなら
        fill(200);
        rect(centerX  - width/2, centerY - height/2, width, height, 10, 10, 10, 10);
        fill(230);
        stroke(230); 
        rect(centerX - width*3/2, centerY - height/2, width, height, 10, 0, 0, 10);
        triangle(centerX, centerY, centerX -width/2, centerY - height/2, centerX - width/2, centerY + height/2);
        fill(0);
        textSize(20);
        text(keylist[1],centerX - width, centerY);
        fill(255);
      }
      if(down_flag == 1){//対象キーの下にあるなら
        fill(200);
        rect(centerX  - width/2, centerY - height/2, width, height, 10, 10, 10, 10);
        fill(230);
        stroke(230); 
        rect(centerX - width/2, centerY + height/2, width, height, 0, 0, 10, 10);
        triangle(centerX, centerY, centerX -width/2, centerY + height/2, centerX +width/2, centerY + height/2);
        fill(0);
        textSize(20);
        text(keylist[4],centerX, centerY + height);
        fill(255);
      }
      if(up_flag == 1){//対象キーの上にあるなら
        fill(200);
        rect(centerX  - width/2, centerY - height/2, width, height, 10, 10, 10, 10);
        fill(230);
        stroke(230); 
        rect(centerX - width/2, centerY - height*3/2, width, height, 10, 10, 0, 0);
        triangle(centerX, centerY, centerX -width/2, centerY - height/2, centerX +width/2, centerY - height/2);
        fill(0);
        textSize(20);
        text(keylist[2],centerX, centerY - height);
        fill(255);
    }
    if(center_flag == 1){//対象キー上にあるなら
      fill(200);
      rect(centerX - width/2, centerY - height/2, width, height, 10, 10, 10, 10);
      fill(0);
      textSize(20);
      text(keylist[0],centerX, centerY);
      fill(255);
    }
  } else if (swipe_mode == 1){//スワイプ処理の記述
    fill(255,255,255);
    rect(centerX - width/2, centerY - height/2, width, height); 
    rect(centerX +width/2, centerY - height/2, width, height,0, 10, 10, 0);
    rect(centerX - width*3/2, centerY - height/2, width, height, 10, 0, 0, 10);
    rect(centerX - width/2, centerY + height/2, width, height, 0, 0, 10, 10);
    rect(centerX - width/2, centerY - height*3/2, width, height, 10, 10, 0, 0);
    fill(0,0,255);
    if(right_flag == 1){//対象キーの左にあるなら
       rect(centerX +width/2, centerY - height/2, width, height);//そこを青色にする
    }
    if(left_flag == 1){//対象キーの右にあるなら
       rect(centerX - width*3/2, centerY - height/2, width, height);//そこを青色にする
    }
    if(down_flag == 1){//対象キーの下にあるなら
       rect(centerX - width/2, centerY + height/2, width, height);//そこを青色にする
    }
    if(up_flag == 1){//対象キーの上にあるなら
      rect(centerX - width/2, centerY - height*3/2, width, height);//そこを青色にする
    }
    if(center_flag == 1){//対象キー上にあるなら
      rect(centerX - width/2, centerY - height/2, width, height);//そこを青色にする
    }
    fill(0);
    textSize(20);
    text(keylist[3],centerX+width, centerY);
    text(keylist[1],centerX - width, centerY);
    text(keylist[4],centerX, centerY + height);
    text(keylist[2],centerX, centerY - height);
    text(keylist[0],centerX, centerY);
    fill(255,255,255);
    } 
  }
  
  void keydraw3(){//キー上の文字の表示
    fill(0);
    textSize(20);
    textAlign(CENTER);
    text(name,centerX, centerY);
    fill(255,255,255);
  }

 void pressed(int x,int y){//キーが押された時の処理
   if(x<= centerX + width/2  && x >= centerX - width/2  && y >= centerY - height/2 && y<= centerY + height/2){
     pressedflag = 1;
     pressedX = x;
     pressedY = y;
     pressed_time = millis();
     center_flag = 1;
     fill(200);
     rect(centerX - width/2, centerY - height/2, width, height, 10, 10, 10, 10);
   }
 }
 void dragged(int x,int y){//ドラッグ中の処理
   if(flick_mode == 1 ){//フリックの処理条件①
     if(abs(x - pressedX) >= 20 ||abs(y - pressedY) >= 20){//フリックの処理条件②
       flick_flag = 1;
       if(abs(x - pressedX) > abs(y - pressedY)){//対象のキーより左右にあるなら
         if(x  > pressedX){//対象のキーより右にあるなら
           right_flag = 1;
           center_flag = 0;
           left_flag = 0;
           up_flag = 0;
           down_flag = 0;
         } else {//対象のキーより左にあるなら
           left_flag = 1;
           center_flag = 0;
           right_flag = 0;
           up_flag = 0;
           down_flag = 0;
        }
      }else{//対象のキーより上下にあるなら
        if(y  > pressedY){//対象のキーより下にあるなら
          down_flag = 1;
          center_flag = 0;
          left_flag = 0;
          right_flag = 0;
          up_flag = 0;
        }else{//対象のキーより上にあるなら
          up_flag = 1;
          center_flag = 0;
          left_flag = 0;
          right_flag = 0;
          down_flag = 0;
        }
      }
    } else {//対象のキー上にあるなら
      up_flag = 0;
      center_flag = 1;
      left_flag = 0;
      right_flag = 0;
      down_flag = 0;
    }
  }
  if (swipe_mode == 1){//スワイプの処理条件
    if (x>= centerX + width/2  && x <= centerX + width*3/2  && y >= centerY - height/2 && y<= centerY + height/2){//対象のキーより右にあるなら
      right_flag = 1;
      center_flag = 0;
      left_flag = 0;
      up_flag = 0;
      down_flag = 0;
    }
    if (x>=centerX - width*3/2 && x <= centerX - width/2 && y >= centerY - height/2 && y <= centerY + height/2){//対象のキーより左にあるなら
      left_flag = 1;
      center_flag = 0;
      right_flag = 0;
      up_flag = 0;
      down_flag = 0;
    }
    if (x>=centerX - width/2 && x <= centerX + width/2 && y >= centerY + height/2 && y<= centerY + height*3/2){//対象のキーより下にあるなら
      down_flag = 1;
      center_flag = 0;
      left_flag = 0;
      right_flag = 0;
      up_flag = 0;
    }
    if (x>=centerX - width/2 && x <= centerX + width/2 && y >= centerY - height*3/2 && y<= centerY - height/2){//対象のキーより上にあるなら
      up_flag = 1;
      center_flag = 0;
      left_flag = 0;
      right_flag = 0;
      down_flag = 0;
    }
    if (x>=centerX - width/2 && x <= centerX + width/2 && y >= centerY - height/2 && y<= centerY + height/2){//対象のキー上にあるなら
      center_flag = 1;
      left_flag = 0;
      right_flag = 0;
      down_flag = 0;
      up_flag = 0;
      }
    }
  }
  
  void released(){//キーを離した時の処理
    pressedflag = 0;
    flick_flag = 0;
    flick_mode= 0;
    swipe_mode= 0;
    pressed_time = 100000000;
    if (right_flag == 1){
      println(keylist[3]);
      str = str + keylist[3];
      recent_str  =  keylist[3];
      trans_str =  trans_str +  keylist[3];
      right_flag = 0;
    }
    if (left_flag == 1){
      println(keylist[1]);
      str = str + keylist[1];
      recent_str  =  keylist[1];
      trans_str =  trans_str +  keylist[1];
      left_flag = 0;
    }
    if (down_flag == 1){
      println(keylist[4]);
      str = str + keylist[4];
      recent_str  =  keylist[4];
      trans_str =  trans_str +  keylist[4];
      down_flag = 0;
    }
    if (up_flag == 1){
      println(keylist[2]);
      str = str + keylist[2];
      recent_str  =  keylist[2];
      trans_str =  trans_str +  keylist[2];
      up_flag = 0;
    }
    if (center_flag == 1){
      str = str + keylist[0];
      recent_str  =  keylist[0];
      trans_str =  trans_str +  keylist[0];
    }
    center_flag = 0;
    String text  =URLEncode(trans_str);
    JSONArray values = loadJSONArray(baseURL + text);
    if(values == null){
    }else{
      JSONArray abc = values.getJSONArray(0);
      JSONArray abclist = abc.getJSONArray(1);
      kekka = abclist.getStringArray();
    }
  }
}

ArrayList<Key> keylist1 = new ArrayList<Key>();
ArrayList<Key> keylist2 = new ArrayList<Key>();
String[] alist = {"あ", "い", "う", "え", "お"};
String[] klist = {"か", "き", "く", "け", "こ"};
String[] slist = {"さ", "し", "す", "せ", "そ"};
String[] tlist = {"た", "ち", "つ", "て", "と"};
String[] nlist = {"な", "に", "ぬ", "ね", "の"};
String[] hlist = {"は", "ひ", "ふ", "へ", "ほ"};
String[] mlist = {"ま", "み", "む", "め", "も"};
String[] ylist = {"や", "「", "ゆ", "」", "よ"};
String[] rlist = {"ら", "り", "る", "れ", "ろ"};
String[] wlist = {"わ", "を", "ん", "ー", "　"};
String[] nulllist = {"　", "　", "　", "　", "　"};
String[] zlist = {"、", "。", "？", "！", "　"};
String[] Alist = {"a", "b", "c", "", ""};
String[] Dlist = {"d", "e", "f", "", ""};
String[] Glist = {"g", "h", "i", "", ""};
String[] Jlist = {"j", "k", "l", "", ""};
String[] Mlist = {"m", "n", "o", "", ""};
String[] Plist = {"p", "q", "r", "s", ""};
String[] Tlist = {"t", "u", "v", "", ""};
String[] Wlist = {"w", "x", "y", "z", ""};
String[] konmalist = {"'", "''", "(", ")", ""};
String[] list1 = {"1", "☆", "♪", "→", ""};
String[] list2 = {"2", "¥", "$", "€", ""};
String[] list3 = {"3", "○", "＊", "・", ""};
String[] list4 = {"4", "+", "×", "÷", ""};
String[] list5 = {"5", "<", "=", ">", ""};
String[] list6 = {"6", "「", "」", ":", ""};
String[] list7 = {"7", "〒", "々", "〆", ""};
String[] list8 = {"8", "x", "y", "z", ""};
String[] list9 = {"'9", "'^", "|", "", ""};
String[] list0 = {"'0", "'～", "…", "", ""};
String[] kakkolist =  {"(", ")", "[", "]", ""};
String[] atlist =  {"@", "#", "/", "&", "_"};
  

void setup(){
  img1 = loadImage("backspace.png");
  img2 = loadImage("syou.jpg");
  PFont font = createFont("Meiryo", 50);
  textFont(font);
  size(500, 450);
  background(102);
  modechange(0);//あいうのモードにする
}

void draw(){
  background(102);
  stroke(0,0,0);
  fill(255,255,255);
  rect( 10, 120, 480, 40);
  predictdraw(kekka);
  for (int i = 0; i < keylist1.size(); i++) {
    keylist1.get(i).keydraw1();
  }
  for (int i = 0; i < keylist1.size(); i++) {
    keylist1.get(i).keydraw3();
  }
  for (int i = 0; i < keylist1.size(); i++) {
    keylist1.get(i).keydraw2();
  }
  rect( 10, 10, 480, 100);
  fill(0);
  textAlign(LEFT);
  textLeading(20);
  if (frameCount % 60 >30 ){
    text(str + "|", 20, 15, 470, 100);
  } else {
    text(str, 20, 15, 470, 100);
  }
  textAlign(CENTER);  
}

void mouseClicked(){//予測変換を選ぶ時の処理
  if ( mouseY > 120 && mouseY < 160){
    float predict_width = 0;
    for (int i = 0; i < kekka.length; i++){
      if (mouseX > 20 + predict_width && mouseX < 20 + predict_width +  textWidth(kekka[i])){
        print(kekka[i]);
        for (int j = 0; j < trans_str.length(); j++){
          str = str.substring(0, str.length()-1);
        }
        str = str + kekka[i];
        for(int k=0; k<kekka.length;k++){
          kekka[k]= "";
        }
        trans_str = "";
      }
      predict_width = predict_width + textWidth(kekka[i]) + 10;
    }
  }
}

void mousePressed(){
  for (int i = 0; i < keylist1.size(); i++) {
    keylist1.get(i).pressed(mouseX, mouseY);
  }
}

void mouseDragged(){
  for (int i = 0; i < keylist1.size(); i++) {
    if(keylist1.get(i).pressedflag ==1){
      keylist1.get(i).dragged(mouseX, mouseY);
    }
  }
}

void mouseReleased(){
  for (int i = 0; i < keylist1.size(); i++) {
    if(keylist1.get(i).pressedflag ==1){
      keylist1.get(i).released();
    }
  }
}

void modechange(int n){
  keylist1.clear();
  if (n == 0){
    keylist1.add(new Key("右", 50, 200));
    keylist1.add(new FlickKey("あ",150, 200, alist));
    keylist1.add(new FlickKey("か",250, 200, klist));
    keylist1.add(new FlickKey("さ",350, 200, slist));
    keylist1.add(new Key("バックスペース",450, 200));
    keylist1.add(new Key("回転",50, 260));
    keylist1.add(new FlickKey("た",150, 260, tlist));
    keylist1.add(new FlickKey("な",250, 260, nlist));
    keylist1.add(new FlickKey("は",350, 260, hlist));
    keylist1.add(new Key("空白",450, 260));
    keylist1.add(new Key("ABC",50, 320));
    keylist1.add(new FlickKey("ま",150, 320, mlist));
    keylist1.add(new FlickKey("や",250, 320, ylist));
    keylist1.add(new FlickKey("ら",350, 320, rlist));
    keylist1.add(new Key("改行",450, 320));
    keylist1.add(new Key("☺",50, 380));
    keylist1.add(new Key("変換",150, 380));
    keylist1.add(new FlickKey("わ",250, 380, wlist));
    keylist1.add(new FlickKey("、。?!",350, 380, zlist));
    keylist1.add(new Key("確定",450, 380));
  }
  if (n == 1){
    keylist1.add(new Key("右",50, 200));
    keylist1.add(new FlickKey("@#/&_",150, 200, atlist));
    keylist1.add(new FlickKey("ABC",250, 200, Alist));
    keylist1.add(new FlickKey("DEF",350, 200, Dlist));
    keylist1.add(new Key("バックスペース",450, 200));
    keylist1.add(new Key("回転",50, 260));
    keylist1.add(new FlickKey("GHI",150, 260, Glist));
    keylist1.add(new FlickKey("JKL",250, 260, Jlist));
    keylist1.add(new FlickKey("MNO",350, 260, Mlist));
    keylist1.add(new Key("空白",450, 260));
    keylist1.add(new Key("☆123",50, 320));
    keylist1.add(new FlickKey("PGRS",150, 320, Plist));
    keylist1.add(new FlickKey("TUV",250, 320, Tlist));
    keylist1.add(new FlickKey("WXYZ",350, 320, Wlist));
    keylist1.add(new Key("改行",450, 320));
    keylist1.add(new Key("☺",50, 380));
    keylist1.add(new Key("a/A",150, 380));
    keylist1.add(new FlickKey("'()",250, 380, konmalist));
    keylist1.add(new FlickKey(".,?!",350, 380, zlist));
    keylist1.add(new Key("確定",450, 380));
  }
  if (n == 2){
    keylist1.add(new Key("右",50, 200));
    keylist1.add(new FlickKey("1",150, 200, list1));
    keylist1.add(new FlickKey("2",250, 200, list2));
    keylist1.add(new FlickKey("3",350, 200, list3));
    keylist1.add(new Key("バックスペース",450, 200));
    keylist1.add(new Key("回転",50, 260));
    keylist1.add(new FlickKey("4",150, 260, list4));
    keylist1.add(new FlickKey("5",250, 260, list5));
    keylist1.add(new FlickKey("6",350, 260, list6));
    keylist1.add(new Key("空白",450, 260));
    keylist1.add(new Key("あいう",50, 320));
    keylist1.add(new FlickKey("7",150, 320, list7));
    keylist1.add(new FlickKey("8",250, 320, list8));
    keylist1.add(new FlickKey("9",350, 320, list9));
    keylist1.add(new Key("改行",450, 320));
    keylist1.add(new Key("☺",50, 380));
    keylist1.add(new FlickKey("()[]",150, 380, kakkolist));
    keylist1.add(new FlickKey("0",250, 380, list0));
    keylist1.add(new FlickKey(".,?!",350, 380, zlist));
    keylist1.add(new Key("確定",450, 380));
  }
}

String[] translist1 ={"は", "ひ", "ふ", "へ", "ほ", "つ", "か", "き", "く", "け", "こ",  "さ", "し", "す", "せ", "そ","た", "ち", "て", "と", "あ", "い", "う", "え", "お", "や", "ゆ", "よ"};
String[] translist2 ={ "ば", "び", "ぶ", "べ", "ぼ", "っ", "が", "ぎ", "ぐ", "げ", "ご",  "ざ", "じ", "ず", "ぜ", "ぞ", "だ", "ぢ", "で", "ど","ぁ", "ぃ", "ぅ", "ぇ", "ぉ", "ゃ", "ゅ", "ょ"};
String[] translist3 ={ "ぱ", "ぴ", "ぷ", "ぺ", "ぽ", "づ"};
void trans(String r_str){
  for( int i = 0; i < translist1.length; i++ ){
    if (r_str == translist1[i]){
      recent_str = translist2[i];
      str = str.substring(0, str.length()-1);
      str = str + recent_str;
      trans_str = trans_str.substring(0, trans_str.length()-1);
      trans_str = trans_str + recent_str;
      return;
    }
  }
  for( int i = 0; i < translist2.length; i++ ){
    if (r_str == translist2[i]){
      if (i  <= 5){
        recent_str = translist3[i];
      }else{
      recent_str = translist1[i];
    }
    str = str.substring(0, str.length()-1);
    str = str + recent_str;
    trans_str = trans_str.substring(0, trans_str.length()-1);
    trans_str = trans_str + recent_str;
    return;
  }
  }
  for( int i = 0; i < translist3.length; i++ ){
    if (r_str == translist3[i]){
      recent_str = translist1[i];
      str = str.substring(0, str.length()-1);
      str = str + recent_str;
      trans_str = trans_str.substring(0, trans_str.length()-1);
      trans_str = trans_str + recent_str;
      return;
    }
  }

}


String URLEncode(String string){
 String output = new String();
 try{
   byte[] input = string.getBytes("UTF-8");
   for(int i=0; i<input.length; i++){
     if(input[i]<0)
       output += '%' + hex(input[i]);
     else if(input[i]==32)
       output += '+';
     else
       output += char(input[i]);
   }
 }
 catch(UnsupportedEncodingException e){
   e.printStackTrace();
 }
 return output;
}


void predictdraw(String[] kekka){
  float predict_width = 0;
  for (int i = 0; i < kekka.length; i++){
    fill(0);
    textAlign(LEFT);
    textLeading(20);
    text(kekka[i], 20 + predict_width, 125, 470 - predict_width, 35);
    textAlign(CENTER);
    predict_width = predict_width + textWidth(kekka[i]) + 10;
  }
}
