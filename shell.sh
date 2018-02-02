#使用方法

#计时
SECONDS=0

number=0

#工程名 将XXX替换成自己的工程名
project_name=YiCai

#scheme名 将XXX替换成自己的sheme名
scheme_name=YiCai

#工程绝对路径
project_path=$(cd `dirname $0`; pwd)
echo''
echo '///-----------'$project_path


#method：app-store, package, ad-hoc, enterprise, development, and developer-id
#打包模式 Debug/Release
development_mode=Debug

#区分包名称而已
pakege_mode=debug

#plist文件所在路径
exportOptionsPlistPath=${project_path}/exportDebug.plist

#指定plist以及类型
if [ $number == 0 ];then
pakege_mode=release
development_mode=Release
exportOptionsPlistPath=${project_path}/exportAdhoc.plist
#exportOptionsPlistPath=${project_path}/exportAppstore.plist
else
pakege_mode=debug
development_mode=Debug
exportOptionsPlistPath=${project_path}/exportDebug.plist
fi
echo ${exportOptionsPlistPath}
#build文件夹路径
build_path=${project_path}/build

#导出.ipa文件所在路径
output_path=/Users/hhly/Desktop
exportIpaPath=${output_path}/${development_mode}


#读取plist文件获取指定参数
appInfoPlistPath=${project_path}/${scheme_name}/info.plist
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" ${appInfoPlistPath})
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" ${appInfoPlistPath})
ipaFullName=iOS_V${bundleShortVersion}_${bundleVersion}_AppStore_$(date +"%Y%m%d")_$(date +"%H%M")_${pakege_mode}


echo ''
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


echo ''
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


#输出总用时
echo "===Finished. Total time: ${SECONDS}s==="

exit 0


