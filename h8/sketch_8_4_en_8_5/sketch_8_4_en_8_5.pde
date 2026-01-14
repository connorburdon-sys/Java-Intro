 import java.util.ArrayList;
 import java.util.HashMap;
 
 
 
 //winkelwagen 8.4//
 
 ArrayList<String> boodschappenlijst = new ArrayList <String> ();
 boodschappenlijst.add("melk 0.5L");
 boodschappenlijst.add("melk 1L");
 boodschappenlijst.add("choco melk");
 boodschappenlijst.add("melk 0.325L");
 boodschappenlijst.add("Karne melk");
 println(boodschappenlijst.get(2));
 println(boodschappenlijst.get(3));
 println(boodschappenlijst.get(4));
 println(boodschappenlijst.get(0));
 println(boodschappenlijst.get(1));
 boodschappenlijst.remove(0);
 println(boodschappenlijst.size());
 
 //telefoonboek 8.5//
 
 HashMap<String,String> telefoonboek = new HashMap<>();
 telefoonboek.put("Connor","16");
  telefoonboek.put("Simon","5000000");
   telefoonboek.put("Cian","2");
 println(telefoonboek.get("Connor"));
 println(telefoonboek.containsKey("Cian"));
