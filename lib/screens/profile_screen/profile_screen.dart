import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memory_box/blocks/bottom_navigation_index_control/bottom_navigation_index_control_cubit.dart';
import 'package:memory_box/blocks/session/session_bloc.dart';
import 'package:memory_box/models/user_model.dart';
import 'package:memory_box/repositories/auth_service.dart';
import 'package:memory_box/repositories/database_service.dart';
import 'package:memory_box/repositories/storage_service.dart';
import 'package:memory_box/screens/splash_screen.dart';
import 'package:memory_box/screens/subscription_screen/subscription_screen.dart';
import 'package:memory_box/widgets/backgoundPattern.dart';
import 'package:memory_box/widgets/circle_textField.dart';
import 'package:memory_box/widgets/deleteAlert.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memory_box/widgets/undoButton.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = 'ProfileScreen';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  final TextEditingController _phoneInputContoller = TextEditingController();
  final TextEditingController _nameInputController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isEditMode = false;

  late UserModel _userModel;

  String? _userName;
  String? _phoneNumber;
  XFile? _selectedImage, _oldImage;

  @override
  void initState() {
    _userModel = context.read<SessionBloc>().state.user!;
    _nameInputController.text = _userModel.displayName ?? 'Без имени';

    _phoneInputContoller.text = PhoneInputFormatter().mask(
      _userModel.phoneNumber ?? '',
    );

    super.initState();
  }

  Future<void> _pickImage() async {
    XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    setState(() {
      _selectedImage = image;
    });
  }

  void _saveChanges() async {
    String? path;

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      if (_selectedImage != null) {
        path = await StorageService.instance.uploadFile(
          file: File(_selectedImage!.path),
          fileName: AuthService.userID,
          fileType: FileType.avatar,
        );
      }

      DatabaseService.instance.updateUserCollection(
        phoneNumber: _phoneInputContoller.text,
        displayName: _nameInputController.text,
        avatarUrl: path,
      );

      context.read<SessionBloc>().add(
            UpdateAccount(
              sessionStatus: SessionStatus.authenticated,
              displayName: _nameInputController.text,
              phoneNumber: toNumericString(_phoneInputContoller.text),
              avatarUrl: path,
            ),
          );
      setState(() {
        _isLoading = false;
      });
      _toogleMode();
    }
  }

  void _undoChanges() {
    setState(() {
      _nameInputController.text = _userName ?? '';
      _phoneInputContoller.text = _phoneNumber ?? '';
      _selectedImage = _oldImage;
      _isEditMode = false;
    });
  }

  void _toogleMode() {
    setState(() {
      _isEditMode = !_isEditMode;

      if (_isEditMode) {
        _userName = _nameInputController.text;
        _phoneNumber = _phoneInputContoller.text;
        _oldImage = _selectedImage;
      }
    });
  }

  void _logOut() {
    context.read<SessionBloc>().add(LogOut());
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      SplashScreen.routeName,
      (route) => false,
    );
  }

  void _deleteAccount() async {
    bool? isDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const DeleteAlert(
          title: 'Точно удалить аккаунт?',
          content:
              'Все аудиофайлы исчезнут и восстановить аккаунт будет невозможно',
        );
      },
    );
    if (isDelete == true) {
      context.read<SessionBloc>().add(
            DeleteAccount(
              uid: _userModel.uid!,
            ),
          );
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        SplashScreen.routeName,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundPattern(
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                primary: true,
                toolbarHeight: 70,
                backgroundColor: Colors.transparent,
                centerTitle: true,
                leading: _isEditMode
                    ? UndoButton(
                        undoChanges: () {
                          _undoChanges();
                        },
                      )
                    : Container(
                        margin: const EdgeInsets.only(left: 6),
                        child: IconButton(
                          icon: SvgPicture.asset(
                            'assets/icons/Burger.svg',
                          ),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                      ),
                title: Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      text: 'Профиль',
                      style: TextStyle(
                        fontFamily: 'TTNorms',
                        fontWeight: FontWeight.w700,
                        fontSize: 36,
                        letterSpacing: 0.5,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '\n Твоя частичка',
                          style: TextStyle(
                            fontFamily: 'TTNorms',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                elevation: 0,
              ),
              body: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        _Avatar(
                          isEditMode: _isEditMode,
                          onPickUpImage: _pickImage,
                          image: _selectedImage?.path != null
                              ? File(_selectedImage!.path)
                              : null,
                          avatarDownloadUrl:
                              context.read<SessionBloc>().state.user?.avatarUrl,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: 180,
                          height: 80,
                          child: TextFormField(
                            controller: _nameInputController,
                            textAlign: TextAlign.center,
                            enabled: _isEditMode ? true : false,
                            maxLength: 12,
                            validator: (value) {
                              if (value != null && value.isEmpty) {
                                return 'Укажите имя пользователя';
                              }

                              return null;
                            },
                            style: const TextStyle(
                              fontFamily: 'TTNorms',
                              fontWeight: FontWeight.w500,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        CircleTextField(
                          controller: _phoneInputContoller,
                          inputFormatters: [PhoneInputFormatter()],
                          editable: _isEditMode ? true : false,
                          validator: (value) {
                            int length = toNumericString(value).length;

                            if (length < 8) {
                              return 'Укажите полный номер телефона';
                            }
                            if (value == null || value.isEmpty) {
                              return 'Поле не может быть пустым';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 0,
                        ),
                        TextButton(
                          onPressed: _isEditMode ? _saveChanges : _toogleMode,
                          child: Text(
                            _isEditMode ? 'Сохранить' : 'Редактировать',
                            style: const TextStyle(
                              fontFamily: 'TTNorms',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (!_isEditMode)
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                SubscriptionScreen.routeName,
                              );
                              context
                                  .read<BottomNavigationIndexControlCubit>()
                                  .changeIndex(-1);
                            },
                            child: const Text(
                              "Подписка",
                              style: TextStyle(
                                fontFamily: 'TTNorms',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                shadows: [
                                  Shadow(
                                      color: Colors.black,
                                      offset: Offset(0, -5))
                                ],
                                color: Colors.transparent,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.black,
                                decorationThickness: 1.1,
                                decorationStyle: TextDecorationStyle.solid,
                              ),
                            ),
                          ),
                        if (!_isEditMode)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.topCenter,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: const LinearProgressIndicator(
                                value: 0.3,
                                minHeight: 24,
                                color: Color.fromRGBO(241, 180, 136, 1),
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(
                          height: 5,
                        ),
                        if (!_isEditMode) const Text('150/500 мб'),
                        if (!_isEditMode)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    _logOut();
                                  },
                                  child: const Text('Выйти из приложения'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _deleteAccount();
                                  },
                                  child: const Text(
                                    'Удалить аккаунт',
                                    style: TextStyle(
                                      color: Color.fromRGBO(226, 119, 119, 1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.isEditMode,
    this.image,
    this.avatarDownloadUrl,
    required this.onPickUpImage,
    Key? key,
  }) : super(key: key);

  final File? image;
  final VoidCallback onPickUpImage;
  final String? avatarDownloadUrl;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        height: 228,
        width: 228,
        color: Colors.grey,
        child: Stack(
          children: [
            if (image?.path != null) ...[
              Image.file(
                File(image!.path),
                height: 228,
                fit: BoxFit.fill,
              ),
            ] else if (avatarDownloadUrl != null) ...[
              Image.network(
                avatarDownloadUrl!,
                height: 228,
                width: 228,
                fit: BoxFit.fitHeight,
              ),
            ] else ...[
              Image.asset(
                'assets/images/nophoto.png',
                color: Colors.white,
              ),
            ],
            if (isEditMode)
              GestureDetector(
                onTap: onPickUpImage,
                child: Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.5),
                  height: 228,
                  width: 228,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/ChosePhoto.svg',
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
