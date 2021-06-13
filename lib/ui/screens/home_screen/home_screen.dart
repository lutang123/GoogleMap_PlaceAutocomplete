import 'package:flutter/material.dart';
import 'package:place_search_and_map/core/api_service/google_place_api.dart';
import 'package:place_search_and_map/core/models/suggestion.dart';
import 'package:place_search_and_map/ui/components/customized_layout_builder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _addressTEC = TextEditingController();
  final TextEditingController _apartmentTEC = TextEditingController();
  final TextEditingController _noteTEC = TextEditingController();

  double latitude = 0.0;
  double longitude = -0.0;

  late String placeId;
  late final String sessionToken;
  late MapController controller;

  List<Suggestion> _addressSuggestionList = [];

  bool _showMap = false;
  bool _logoVisible = true;

  Future<void> _onChanged(String text) async {
    _logoVisible = false;
    _showMap = false;
    final lang = context.locale.toString();
    _addressSuggestionList = await PlaceApiService.fetchSuggestions(
      input: text,
      lang: lang,
      sessionToken: sessionToken,
    );
    if (text.isEmpty) {
      _addressSuggestionList.clear();
    }
    setState(() {});
  }

  Future<void> _onTapSuggestion(Suggestion suggestion) async {
    //dismiss keyboard
    FocusScope.of(context).unfocus();

    final placeLatLng =
        await PlaceApiService.geocoding(suggestion.description);
    if (placeLatLng != null) {
      //assign value to these variables,which will be passed later.
      placeId = suggestion.placeId;
      latitude = placeLatLng.lat;
      longitude = placeLatLng.lng;

      setState(() {
        _addressTEC.text = suggestion.description;
        _addressSuggestionList.clear();
        _logoVisible = false;
        _showMap = true;
        //redirect map
        controller.center = latlng.LatLng(placeLatLng.lat, placeLatLng.lng);
      });
    }
  }

  // first value of latitude and longitude suggested address are assigned on _onTapSuggestion()
  Future<void> _onScaleEnd(ScaleEndDetails details) async {
    //when drag the map, latitude and longitude are updated
    latitude = controller.center.latitude;
    longitude = controller.center.longitude;
    // using new latitude and longitude to get address
    final address = await PlaceApiService.reverseGeocoding(
        lat: latitude, lng: longitude);
    // update input text
    _addressTEC.text = address;
  }

  //add loading/wait
  Future<void> _save() async {
    final FormState formState = _formKey.currentState!;
    if (formState.validate()) {
      formState.save();

      final pd = showProgressDialog(context);
      pd.show();
      BraiseLogger.info(
          message:
              'placeId: $placeId; latitude: $latitude,longitude: $longitude, '
              'suite: ${_apartmentTEC.text},note: ${_noteTEC.text}');
      try {
        final success = await PlaceApiService.saveSelectedAddress(
          sessionToken: sessionToken,
          placeId: placeId,
          latitude: latitude,
          longitude: longitude,
          suite: _apartmentTEC.text.trim(),
          note: _noteTEC.text.trim(),
        );
        if (success) {
          widget.closeFunction();
        }
        pd.dismiss();
      } on APIError catch (e, stackTrace) {
        await BraiseLogger.error(throwable: e, stackTrace: stackTrace);
        pd.dismiss();
        await showError(context, e.message);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    sessionToken = const Uuid().v4();
    controller = MapController(location: latlng.LatLng(latitude, longitude));
  }

  @override
  void dispose() {
    _addressTEC.dispose();
    _apartmentTEC.dispose();
    _noteTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomizedLayoutBuilder(
        children: [
          Visibility(
            visible: _logoVisible,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 50.0),
                  child: Image.asset(ImagePath.braiseLogo,
                      width: kLogoWidth, height: kLogoHeight),
                ),
                const Text(
                  "AddAddress.enter",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ).tr(),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Address search Form
          buildAddressSearchForm(),
          if (_showMap) buildMapAndOther(),
          const Spacer(),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Form buildAddressSearchForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address
          TextFormField(
            keyboardType: TextInputType.streetAddress,
            controller: _addressTEC,
            maxLines: null,
            validator: requiredValidator,
            style: Theme.of(context).textTheme.bodyText1,
            onChanged: _onChanged,
            cursorColor: kPrimaryColor,
            decoration: defaultInputDecoration(
              label: 'AddAddress.type',
              icon: Icons.location_on_outlined,
              // ignore: avoid_bool_literals_in_conditional_expressions
              hasSuffixIcon: _addressTEC.text.isNotEmpty ? true : false,
              isOtherIcon: true,
              otherIcon: Icons.close,
              onTap: () {
                setState(() {
                  _addressTEC.clear();
                  _addressSuggestionList.clear();
                });
              },
            ),
          ),
          if (_addressSuggestionList.isNotEmpty)
            ..._addressSuggestionList.map((suggestion) => GestureDetector(
                  onTap: () => _onTapSuggestion(suggestion),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      suggestion.description,
                      textAlign: TextAlign.left,
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  // Column buildMapAndOther() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: [
  //       buildAddressDetails(),
  //       const SizedBox(height: 20),
  //       MapWidget(controller: controller, onScaleEnd: _onScaleEnd),
  //       const SizedBox(height: 20),
  //       BraiseOutlineButton(
  //         onPressed: _save,
  //         text: 'AddAddress.add_address',
  //       ),
  //       const SizedBox(height: 20)
  //     ],
  //   );
  // }

  Row buildAddressDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.text,
            controller: _apartmentTEC,
            decoration: defaultInputDecoration(
              label: 'AddAddress.suite',
              icon: Icons.location_on_outlined,
            ),
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.text,
            controller: _noteTEC,
            decoration: defaultInputDecoration(
              label: 'AddAddress.buzz_code',
              icon: Icons.location_on_outlined,
            ),
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
      ],
    );
  }
}
