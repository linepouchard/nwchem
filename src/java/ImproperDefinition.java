import java.io.*;

public class ImproperDefinition{

    public int atomi,atomj,atomk,atoml;
    public int type, source;
    public int multi1,multi2,multi3;
    public int source1,source2,source3;
    public double improper1,improper2,improper3,force1,force2,force3;

    public ImproperDefinition(String card1, String card2){
	atomi=Integer.parseInt(card1.substring(5,10).trim());
	atomj=Integer.parseInt(card1.substring(10,15).trim());
	atomk=Integer.parseInt(card1.substring(15,20).trim());
	atoml=Integer.parseInt(card1.substring(20,25).trim());
	type=Integer.parseInt(card1.substring(25,30).trim());
	source3=Integer.parseInt(card1.substring(34,35).trim());
	source1=source3;
	source2=source3;
	if(card1.charAt(32)!=' ') source1=Integer.parseInt(card1.substring(30,33).trim());
	if(card1.charAt(33)!=' ') source2=Integer.parseInt(card1.substring(33,34).trim());
        source=source1;
	multi1=Integer.parseInt(card2.substring(0,3).trim());
	multi2=Integer.parseInt(card2.substring(25,28).trim());
	multi3=Integer.parseInt(card2.substring(50,53).trim());
	improper1=Double.valueOf(card2.substring(3,13)).doubleValue();
	improper2=Double.valueOf(card2.substring(28,38)).doubleValue();
	improper3=Double.valueOf(card2.substring(53,63)).doubleValue();
	force1=Double.valueOf(card2.substring(13,25)).doubleValue();
	force2=Double.valueOf(card2.substring(38,50)).doubleValue();
	force3=Double.valueOf(card2.substring(63,75)).doubleValue();
    }

}
