import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:untitled/assets/colors/colors.dart';
import 'package:untitled/screens/register/sign_up.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  var formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var isObscure = true.obs;

  get sharedPreferences => null;

  validateForm()
  {
    if(emailController.text.isNotEmpty
        && passwordController.text.isNotEmpty)
    {
      //allow user to login
      loginNow();
    }
    else
    {
      Fluttertoast.showToast(msg: "Please provide email and password");
    }
  }
  loginNow() async
  {
    //showDialog(context: context, builder: (context)

     // return LoadingDialogWidget(message: "Checking credentials",););

    User? currentUser;

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth)
    {
      currentUser = auth.user;
    }).catchError((errorMessage)
    {
      Fluttertoast.showToast(msg: "Error Occurred: \n $errorMessage");
    });

    if(currentUser != null)
    {
      checkIfUserRecordExists(currentUser!);
    }
  }

  checkIfUserRecordExists(User currentUser)async
  {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser.uid)
        .get()
        .then((record) async
    {
      if(record.exists)
      {
        if(record.data()!["status"]== "approved")
        {
          await sharedPreferences!.setString("uid",record.data()!["uid"]);
          await sharedPreferences!.setString("email",record.data()!["email"]);
          await sharedPreferences!.setString("name",record.data()!["name"]);
          await sharedPreferences!.setString("photoUrl", record.data()!["photoUrl"]);

          List<String> userCartList = record.data()!["userCart"].cast<String>();
          await sharedPreferences!.setStringList("userCart", userCartList);
          
          //home screen
        }
        else
        {
          FirebaseAuth.instance.signOut();
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "You have blocked by admin");
        }
      }
      else
      {
        FirebaseAuth.instance.signOut();
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "This record do not exists");
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.black,
      body: LayoutBuilder(
          builder: (context,cons)
          {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: cons.maxHeight,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [


                    //Image
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 150,
                      child: Image.asset("lib/assets/images/pngwing 1.png",
                      ),
                    ),
                    



                    //Login Screen sign_in form
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.all(Radius.circular(60),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 8,
                                color: Colors.black26,
                                offset: Offset(0,-3),
                              ),
                            ]
                        ),

                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(30, 30, 30, 8),
                          child: Column(
                            children: [
                              Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: emailController,
                                      validator: (val) => val == "" ? "please write email": null,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          Icons.email_outlined,
                                          color: Colors.black,
                                        ),
                                        hintText: "email...",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide:const  BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide:const  BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide:const  BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide:const  BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                ),


                                const SizedBox(
                                  height: 18,),


                                //password

                                Obx(
                                        ()=> TextFormField(
                                      controller: passwordController,
                                      obscureText: isObscure.value,
                                      validator: (val) => val == "" ? "Please write password": null,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          Icons.vpn_key_outlined,
                                          color: Colors.black,
                                        ),
                                        suffixIcon: Obx(() => GestureDetector(
                                          onTap: () {
                                            isObscure.value = !isObscure.value;
                                          },
                                          child: Icon(
                                            isObscure.value ? Icons.visibility_off : Icons.visibility,
                                            color: Colors.black,
                                          ),
                                        ),
                                        ),
                                        hintText: "password...",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide:const  BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide:const  BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide:const  BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide:const  BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                    )
                                      ),
                                    //button
                                    Material(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(30),
                                      child: InkWell(
                                        onTap: ()
                                        {
                                          if(formKey.currentState!.validate())
                                          {
                                            loginNow();
                                          }
                                          validateForm();
                                        },
                                        borderRadius: BorderRadius.circular(30),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 28,
                                          ),
                                          child: Text(
                                            "Login",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                          ),

                           const SizedBox(
                             height: 16,
                           ),


                          Row(
                            children: [
                              const Text(
                                  "Do not have an Account?"
                              ),
                              TextButton(
                                onPressed: (){
                                  Get.to(SignUp());
                                },
                                child:const  Text(
                                  "Register Here",
                                  style: TextStyle(color: Colors.pinkAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ]
                ),
            ),
            );
          }
          ),
            );
  }
}
