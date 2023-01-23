import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({
    Key? key,
    this.onChange,
    this.controller,
  }) : super(key: key);

  final void Function(String)? onChange;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.shade100,
        ),
        child: Row(
          children: <Widget>[
            Flexible(
              flex: 2,
              child: SizedBox(
                height: 30,
                width: 30,
                child: SvgPicture.asset(
                  'Assets/Svg/Search.svg',
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 9,
              child: TextFormField(
                enableSuggestions: false,
                controller: controller,
                autocorrect: false,
                style: kSearchTextStyle,
                cursorColor: Theme.of(context).iconTheme.color,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: 'Enter Artist or Song Name',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                onFieldSubmitted: onChange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const kSearchTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.5,
);
