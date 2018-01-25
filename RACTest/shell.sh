#使用方法

#计时
SECONDS=0

#输入包类型
echo "Place enter the number you want to export ? [ 0:ad-hoc 1:app-store 2:Debug] "

##
read number
while([[ $number != 0 ]] && [[ $number != 1 ]] && [[ $number != 2 ]])
do
echo "Error! Should enter 0、1 or 2"
echo "Place enter the number you want to export ? [ 0:ad-hoc 1:app-store 2:Debug] "
read number
done


#工程名 将XXX替换成自己的工程名
project_name=RACTest

#scheme名 将XXX替换成自己的sheme名
scheme_name=RACTest

#工程绝对路径
project_path=$(cd `dirname $0`; pwd)
echo''
echo '///-----------'$project_path


#method：app-store, package, ad-hoc, enterprise, development, and developer-id
#打包模式 Debug/Release
development_mode=Debug

#区分包名称而已
pakege_mode=debug

#指定plist以及类型
if [ $number == 0 ];then
pakege_mode=release
development_mode=Release
exportOptionsPlistPath=${project_path}/exportAdhoc.plist
elif [ $number == 1 ];then
pakege_mode=release
development_mode=Release
exportOptionsPlistPath=${project_path}/exportAppstore.plist
else
pakege_mode=debug
development_mode=Debug
exportOptionsPlistPath=${project_path}/exportDebug.plist
fi

#build文件夹路径
build_path=${project_path}/build

#plist文件所在路径
exportOptionsPlistPath=${project_path}/exportDebug.plist

#导出.ipa文件所在路径
output_path=/Users/hhly/Desktop
exportIpaPath=${output_path}/${development_mode}


#读取plist文件获取指定参数
appInfoPlistPath=${project_path}/${scheme_name}/info.plist
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" ${appInfoPlistPath})
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" ${appInfoPlistPath})
ipaFullName=iOS_V${bundleShortVersion}_${bundleVersion}_AppStore_$(date +"%Y%m%d")_$(date +"%H%M")_${pakege_mode}


echo''
echo '///-----------'
echo '/// 正在清理工程'
echo '///-----------'
xcodebuild \
clean -configuration ${development_mode} -quiet  || exit


echo''
echo '///-----------'
echo '/// 正在编译工程:'${development_mode}
echo '///-----------'
xcodebuild \
archive -workspace ${project_path}/${project_name}.xcworkspace \
-scheme ${scheme_name} \
-configuration ${development_mode} \
-archivePath ${build_path}/${project_name}.xcarchive  -quiet  || exit


echo''
echo '///----------'
echo '/// 开始ipa打包'${ipaFullName}
echo '///----------'
xcodebuild -exportArchive -archivePath ${build_path}/${project_name}.xcarchive \
-configuration ${development_mode} \
-exportPath ${exportIpaPath} \
-exportOptionsPlist ${exportOptionsPlistPath} \
-quiet || exit

#重命名  拷贝:cp  重命名:mv
#cp "${exportIpaPath}/${project_name}.ipa" "${exportIpaPath}/${ipaFullName}.ipa"
mv "${exportIpaPath}/${project_name}.ipa" "${exportIpaPath}/${ipaFullName}.ipa"
echo''
echo '///----------'
echo "重命名完成"$exportIpaPath/$ipaFullName.ipa
echo '///----------'

if [ -e $exportIpaPath/$ipaFullName.ipa ]; then
echo''
echo '///----------'
echo '/// ipa包已导出'
echo '///----------'
open $exportIpaPath
else
echo''
echo '///-------------'
echo '/// ipa包导出失败 '
echo '///-------------'
fi

echo''
echo '///-------------'
echo '/// 开始发布ipa包'
echo '///-------------'

if [ $number == 1 ];then
echo''
echo '///-------------'
echo '/// 开始上传App Store'
echo '///-------------'
#验证并上传到App Store
# 将-u 后面的XXX替换成自己的AppleID的账号，-p后面的XXX替换成自己的密码
altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
"$altoolPath" --validate-app -f ${exportIpaPath}/${ipaFullName}.ipa -u XXX -p XXX -t ios --output-format xml
"$altoolPath" --upload-app -f ${exportIpaPath}/${ipaFullName}.ipa -u  XXX -p XXX -t ios --output-format xml
else



echo''
#echo '///-------------'
#echo '/// 开始上传 fir' $exportIpaPath/$ipaFullName.ipa
#echo '///-------------'
##上传到Fir  - 将XXX替换成自己的Fir平台的token
#export LANG="en_US.UTF-8"
#fir login -T ab1a7d28504bb1d63f9365603833fdba # 5b2810e5544fa810661d4adf2683f6fd # ab1a7d28504bb1d63f9365603833fdba
#fir publish $exportIpaPath/$ipaFullName.ipa -Q -V -c ${project_path}/log.txt

fi




set from=ouyxc1145@2ncai.com smtp=mx.2ncai.com
set smtp-auth-user=ouyxc1145 smtp-auth-password=Pass2010 smtp-auth=login



##svn 地址
#svnGoal=http://ouyangxiongchun@192.168.74.7:8888/Lotto/03Release/Mobile%20-%20iOS/$(date +"%Y%m")/$ipaFullName.ipa
#if [ $number == 2 ];then
#svnGoal=http://ouyangxiongchun@192.168.74.7:8888/Lotto/04Baseline/Mobile%20-%20iOS/v${bundleShortVersion}/$ipaFullName.ipa
#fi
#
#echo''
#echo '///-------------'
#echo '/// 上传SVN'
#echo 'from' $exportIpaPath/$ipaFullName.ipa
#echo 'to' $svnGoal
#echo '///-------------'
#
##更新到svn
##svn import $exportIpaPath/$ipaFullName.ipa $svnGoal -F ${project_path}/log.txt
#svn import $exportIpaPath/$ipaFullName.ipa $svnGoal --username=ouyangxiongchun --password=ouyangxiongchun -F ${project_path}/log.txt






echo''
echo '///-------------'
echo '/// 开始发邮件'
echo '///-------------'
#发邮件
sendEmail -v -f ouyxc1145@2ncai.com -t ouyxc1145@2ncai.com -s mx.2ncai.com:587 -xu ouyxc1145 -xp Pass2010 -u "test" -m "sendemail" -o tls=yes message-charset=utf-8
#echo 'ouyang' |  mail -v -s "mail test oyxc"  ouyxc1145@2ncai.com





#打包zip
#zip -r olinone.ipa Payload

#输出总用时
echo "===Finished. Total time: ${SECONDS}s==="


echo''
echo '///-------------'
echo '/// 任务完成'
echo '///-------------'
#通知
osascript -e 'display notification "打包成功！" with title "任务完成"'

exit 0


