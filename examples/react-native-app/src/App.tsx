import React from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  useColorScheme,
} from 'react-native';

function App(): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';

  const bgColor = isDarkMode ? '#1a1a2e' : '#f5f5ff';
  const textColor = isDarkMode ? '#ffffff' : '#1a1a2e';

  return (
    <SafeAreaView style={[styles.container, {backgroundColor: bgColor}]}>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <ScrollView contentInsetAdjustmentBehavior="automatic">
        <View style={styles.hero}>
          <Text style={styles.logo}>⚡</Text>
          <Text style={[styles.title, {color: textColor}]}>DNYFappbuilder</Text>
          <Text style={styles.subtitle}>React Native Example App</Text>
          <Text style={styles.version}>Built with DNYFappbuilder v2.0.0</Text>

          <TouchableOpacity style={styles.button}>
            <Text style={styles.buttonText}>🚀 Get Started</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.cards}>
          {[
            {icon: '📱', title: 'Android & iOS', desc: 'Build for both platforms'},
            {icon: '⚡', title: 'Fast Builds',   desc: 'Parallel build system'},
            {icon: '🔧', title: 'Auto Install',  desc: 'Deploy direct to device'},
          ].map(card => (
            <View key={card.title} style={styles.card}>
              <Text style={styles.cardIcon}>{card.icon}</Text>
              <Text style={[styles.cardTitle, {color: textColor}]}>{card.title}</Text>
              <Text style={styles.cardDesc}>{card.desc}</Text>
            </View>
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container:  {flex: 1},
  hero:       {alignItems: 'center', paddingTop: 60, paddingBottom: 40, paddingHorizontal: 24},
  logo:       {fontSize: 64, marginBottom: 16},
  title:      {fontSize: 32, fontWeight: '800', letterSpacing: -1},
  subtitle:   {fontSize: 16, color: '#6C63FF', fontWeight: '600', marginTop: 4},
  version:    {fontSize: 13, color: '#888', marginTop: 8, marginBottom: 32},
  button:     {backgroundColor: '#6C63FF', paddingHorizontal: 36, paddingVertical: 14, borderRadius: 30},
  buttonText: {color: '#fff', fontWeight: '700', fontSize: 16},
  cards:      {flexDirection: 'row', flexWrap: 'wrap', padding: 16, gap: 12},
  card:       {flex: 1, minWidth: 140, backgroundColor: '#6C63FF22', borderRadius: 16, padding: 16, alignItems: 'center'},
  cardIcon:   {fontSize: 28, marginBottom: 8},
  cardTitle:  {fontWeight: '700', fontSize: 14, marginBottom: 4},
  cardDesc:   {fontSize: 12, color: '#888', textAlign: 'center'},
});

export default App;
