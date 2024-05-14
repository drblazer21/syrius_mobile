import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

class TokenListScreen extends StatefulWidget {
  final Function(Token) onSelect;
  final AccountInfo accountInfo;
  final Token selectedToken;

  const TokenListScreen({
    super.key,
    required this.onSelect,
    required this.accountInfo,
    required this.selectedToken,
  });

  @override
  State<TokenListScreen> createState() => _TokenListScreenState();
}

class _TokenListScreenState extends State<TokenListScreen> {
  final TextEditingController _keywordController = TextEditingController();

  final List<Token> _tokensWithBalance = [];

  @override
  void initState() {
    super.initState();
    _tokensWithBalance.addAll(kDualCoin);
    _addTokensWithBalance(widget.accountInfo);
  }

  @override
  Widget build(BuildContext context) {
    final Iterable<Token> tokens = _searchToken(
      tokens: _tokensWithBalance,
      keyword: _keywordController.text,
    );

    return CustomAppbarScreen(
      appbarTitle: AppLocalizations.of(context)!.zenonTokenStandard,
      withLateralPadding: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kHorizontalPagePaddingDimension,
            ),
            child: TextField(
              controller: _keywordController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.tokenSearch,
                prefixIcon: const Icon(
                  Icons.search,
                ),
              ),
              keyboardType: TextInputType.text,
              onChanged: (value) {
                setState(() {});
              },
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(
            height: 30.0,
          ),
          Expanded(
            child: tokens.isEmpty
                ? SyriusErrorWidget(
                    AppLocalizations.of(context)!.nothingToShow,
                  )
                : _buildTokenList(tokens: tokens),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  void _addTokensWithBalance(AccountInfo accountInfo) {
    for (final balanceInfo in accountInfo.balanceInfoList!) {
      if (balanceInfo.balance! > BigInt.zero &&
          !_tokensWithBalance.contains(balanceInfo.token) &&
          balanceInfo.token != null) {
        _tokensWithBalance.add(balanceInfo.token!);
      }
    }
  }

  Widget _buildTokenList({
    required Iterable<Token> tokens,
  }) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: tokens.length,
      itemBuilder: (_, index) {
        final token = tokens.elementAt(index);
        final bool isSelected = widget.selectedToken == token;

        return TokenPriceListItem(
          iconFileName: 'zn_icon',
          isSelected: isSelected,
          onTap: () {
            widget.onSelect(token);
            Navigator.pop(context);
          },
          token: token,
          tokenAmount: widget.accountInfo.getBalance(token.tokenStandard),
        );
      },
    );
  }

  Iterable<Token> _searchToken({
    required List<Token> tokens,
    required String keyword,
  }) {
    return tokens.where(
      (token) {
        final String name = token.name.toLowerCase();
        final String symbol = token.symbol.toLowerCase();
        keyword = keyword.toLowerCase().trim();

        return name.contains(keyword) || symbol.contains(keyword);
      },
    );
  }
}
