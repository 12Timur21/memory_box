import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memory_box/blocks/session/session_bloc.dart';
import 'package:memory_box/models/user_model.dart';
import 'package:memory_box/repositories/database_service.dart';
import 'package:memory_box/resources/app_coloros.dart';
import 'package:memory_box/resources/app_icons.dart';
import 'package:memory_box/widgets/backgoundPattern.dart';

class SubscriptionScreen extends StatefulWidget {
  static const routeName = 'SubscriptionScreen';

  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late SubscriptionType _subsciptionType;
  @override
  void initState() {
    _subsciptionType =
        context.read<SessionBloc>().state.user?.subscriptionType ??
            SubscriptionType.noSubscription;
    super.initState();
  }

  void _selectNewPlan(SubscriptionType subscriptionType) {
    setState(() {
      _subsciptionType = subscriptionType;
    });
  }

  void _changePlan() {
    DatabaseService.instance.updateUserCollection(
      subscriptionType: _subsciptionType,
    );
    context.read<SessionBloc>().add(
          UpdateAccount(
            subscriptionType: _subsciptionType,
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("План изменен"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundPattern(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          primary: true,
          toolbarHeight: 70,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading: Container(
            margin: const EdgeInsets.only(left: 6),
            child: IconButton(
              icon: SvgPicture.asset(
                AppIcons.burger,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          title: Container(
            margin: const EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                text: 'Подписка',
                style: TextStyle(
                  fontFamily: 'TTNorms',
                  fontWeight: FontWeight.w700,
                  fontSize: 36,
                  letterSpacing: 0.5,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '\n Расширь возможности',
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
          decoration: BoxDecoration(
            color: AppColors.wildSand,
            borderRadius: const BorderRadius.all(
              Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 6,
                blurRadius: 8,
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 25,
                ),
                const Text(
                  'Выбери подписку',
                  style: TextStyle(
                    fontFamily: 'TTNorms',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                BlocBuilder<SessionBloc, SessionState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        Expanded(
                          child: _SubscriptionPlanTale(
                              duringString: 'в месяц',
                              price: 300,
                              isSelected:
                                  _subsciptionType == SubscriptionType.month,
                              onSelect: () {
                                _selectNewPlan(SubscriptionType.month);
                              }),
                        ),
                        Expanded(
                          child: _SubscriptionPlanTale(
                            duringString: 'в год',
                            price: 1800,
                            isSelected:
                                _subsciptionType == SubscriptionType.year,
                            onSelect: () {
                              _selectNewPlan(SubscriptionType.year);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 40,
                  ),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Что даёт подписка:',
                          style: TextStyle(
                            fontFamily: 'TTNorms',
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.infinite,
                                width: 25,
                              ),
                              const SizedBox(width: 10),
                              const Text('Неограниченая память'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.cloudUpload,
                                width: 25,
                              ),
                              const SizedBox(width: 10),
                              const Text('Все файлы хранятся в облаке'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.paperDownload,
                                width: 25,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                  'Возможность скачивать без ограничений'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextButton(
                  child: const Text(
                    'Подписаться на месяц',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(51),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      AppColors.tacao,
                    ),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 100,
                      ),
                    ),
                  ),
                  onPressed: _changePlan,
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionPlanTale extends StatelessWidget {
  const _SubscriptionPlanTale({
    required this.isSelected,
    required this.price,
    required this.duringString,
    required this.onSelect,
    Key? key,
  }) : super(key: key);

  final bool isSelected;
  final int price;
  final String duringString;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 50,
        bottom: 10,
      ),
      margin: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 4),
            color: Color.fromRGBO(0, 0, 0, 0.1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$priceр',
            style: const TextStyle(
              fontFamily: 'TTNorms',
              fontWeight: FontWeight.w400,
              fontSize: 24,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            duringString,
            style: const TextStyle(
              fontFamily: 'TTNorms',
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 100,
            height: 100,
            child: IconButton(
              onPressed: onSelect,
              icon: isSelected
                  ? SvgPicture.asset(
                      'assets/icons/SubmitCircle.svg',
                    )
                  : SvgPicture.asset(
                      'assets/icons/Circle.svg',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
