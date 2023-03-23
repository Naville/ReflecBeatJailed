#JB-Free RBAC+
**Last maintained Apr 2, 2016**

>>First. Create empty project in Xcode 7. Change BundleIdentifier to whatever you want

>>Login/Register a free iOS Developer ID


>>In capibilities. Select Keychain Sharing & App Groups

>>A new **.entitlements will appear on the left. Pull it out to project directory.

>>Unzip Decrypted game ipa. ldid -S/PATH/TO/.ENTITLEMENTS /PATH/TO/BINARY

>>Change **.app to RBPLUS.app, rename "Reflec Beat plus" in RBPLUS.app into RBPLUS.

>>EDIT Info.plist. Change bundleidentifer to your desired one, change CFBundleExecutable value to RBPLUS.

>>ZIP BACK. run make

>>Xcode->Preferences->YourID->ViewDetails->Provisioning Files->. Choose the one you just created,right click->Show in Finder->>Save that .mobile provision

>>./Patchapp.sh patch /PATH/TO/NEW/IPA /PATH/TO/PROVISION



#Coding


>[objc_getClass("CLASSNAME") swizzleInstanceMethod:@selector(subpostArray) withReplacement:JGMethodReplacementProviderBlock {
    return JGMethodReplacement(id, const Class *) {
    	NSMutableArray* ret = JGOriginalImplementation(id);

    };
	}];

#Explanation
1.	objc_getClass("CLASSNAME")  dynamically get the class object, equals to %hook CLASSNAME
2.	swizzleInstanceMethod is for hooking InstanceMethod (start with -(returnValueType))
3.	swizzleClassMethod is for hooking ClassMethod (start with +(returnValueType))
4.@selector(subpostArray) is the signature of the method. Convert:
	Remove all Variable Names/VariableTypes/Spaces

	E.X.: "-(int)SomeCoolFunction:(NSString*)string  WithNumber:(NSNumber*)Num" is Equal to @selector(SomeCoolFunction:WithNumber:)

5. Function Signature of the method. the first one is return value type. Don't Change the second one, starting from the third,is the arguments.
	SO THE PREVIOUS EXAMPLE GOES TO:
	return JGMethodReplacement(int, const Class *,NSString* arg1,NSNumber* arg2) {
6.JGOriginalImplementation() is like %orig. pass in all the arguments in No 5 except the Class*



#Issues
InstantCrash/Trap5:

Use MachOView, open the compiled .dylib
	For each arch->Load Commands->Search For CydiaSubtrate->change "Command" on the right side to 80000018