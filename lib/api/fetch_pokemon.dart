import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:el_poke/constants/constants.dart';
import 'package:el_poke/models/pokemon.dart';

import '../constants/constants.dart';
import '../models/pokemon.dart';

/// Parse [String] to [int] in a functional way using [IOEither].
IOEither<String, int> _parseStringToInt(String str) => IOEither.tryCatch(
      () => int.parse(str),
      (_, __) =>
          'Solo numeros, por favor!',
    );

/// Validate the pokemon id inserted by the user:
/// 1. Parse [String] from the user to [int]
/// 2. Check pokemon id in valid range
///
/// Chain (1) and (2) using `flatMap`.
IOEither<String, int> _validateUserPokemonId(String pokemonId) =>
    _parseStringToInt(pokemonId).flatMap(
      (intPokemonId) => IOEither.fromPredicate(
        intPokemonId,
        (id) =>
            id >= Constants.minimumPokemonId &&
            id <= Constants.maximumPokemonId,
        (id) =>
            'No existe el numero de este pokemon $id: Tiene que ser de este numero ${Constants.minimumPokemonId} a este otro ${Constants.maximumPokemonId + 1}!',
      ),
    );

/// Make HTTP request to fetch pokemon information from the pokeAPI
/// using [TaskEither] to perform an async request in a composable way.
TaskEither<String, Pokemon> fetchPokemon(int pokemonId) => TaskEither.tryCatch(
      () async {
        final url = Uri.parse(Constants.requestAPIUrl(pokemonId));
        final response = await http.get(url);
        return Pokemon.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      },
      (error, __) => 'Ni idea que paso: $error',
    );


TaskEither<String, Pokemon> fetchPokemonFromUserInput(String pokemonId) =>
    _validateUserPokemonId(pokemonId).flatMapTask(fetchPokemon);

