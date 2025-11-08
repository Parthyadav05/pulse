# DailyPulse Charts & Analytics Guide

## Overview

DailyPulse now includes comprehensive visual analytics with three interactive charts to help you understand your mood patterns better.

## Charts Included

### 1. Sentiment Distribution Pie Chart

**Location**: Analytics tab, second card

**What it shows**:
- Visual breakdown of your mood sentiment distribution
- Three segments: Positive (green), Neutral (orange), Negative (red)
- Percentage values displayed on each segment
- Color-coded legend at the bottom

**Use case**:
- Quick overview of your overall emotional state
- Identify if you're trending positive, negative, or balanced
- Track changes in your emotional distribution over time

**Features**:
- Interactive pie chart with touch feedback
- Percentage labels on each segment
- Automatic adjustment based on data
- Hidden segments when count is 0

---

### 2. Mood Trend Line Chart

**Location**: Analytics tab, third card

**What it shows**:
- Daily average sentiment over time
- Line graph showing mood trends
- Dots colored by sentiment (green/orange/red)
- Time selector: 7 days or 30 days

**Use case**:
- Identify patterns in your mood over time
- See if you're improving or declining
- Find specific days with mood changes
- Understand weekly or monthly trends

**Features**:
- **Interactive timeline**: Tap dots for details
- **Date tooltips**: Shows date and sentiment on tap
- **Gradient fill**: Visual area under the curve
- **Time selection**: Toggle between 7-day and 30-day views
- **Curved line**: Smooth transitions between points
- **Grid lines**: Easy reference for sentiment levels

**Y-axis labels**:
- +1: Positive
- 0: Neutral
- -1: Negative

**X-axis labels**:
- Shows dates (e.g., "Nov 08")
- Adaptive labeling based on selected period

---

### 3. Emoji Frequency Bar Chart

**Location**: Analytics tab, fourth card

**What it shows**:
- How often you use each mood emoji
- Vertical bars for up to 8 most-used emojis
- Color-coded by sentiment
- Count displayed on Y-axis

**Use case**:
- Discover your most common emotions
- See which moods dominate your entries
- Identify emotional patterns
- Compare frequency between different moods

**Features**:
- **Interactive bars**: Tap for exact count
- **Sentiment colors**:
  - Green bars: Positive emojis (😄, 😊, 😌)
  - Orange bars: Neutral emoji (😐)
  - Red bars: Negative emojis (😕, 😢, 😠, 😰)
- **Background shading**: Shows maximum potential
- **Auto-scaling**: Y-axis adjusts to your data
- **Top 8 display**: Shows your most-used emojis

---

## How to Read the Charts

### Understanding Sentiment

All charts use a 3-tier sentiment system:
- **Positive (+1)**: Happy, Relaxed, Very Happy
- **Neutral (0)**: Neutral feelings
- **Negative (-1)**: Sad, Angry, Anxious, Confused

### Interpreting the Trend Chart

**Upward trend**: Mood improving over time
**Downward trend**: Mood declining over time
**Flat line**: Stable mood
**Spikes**: Significant mood events on specific days

### Reading Percentages

In the pie chart:
- **>70% Positive**: Doing great!
- **50-70% Positive**: Good balance
- **<50% Positive**: Consider self-care
- **>50% Negative**: May need support

---

## Chart Interactions

### Pie Chart
- **View**: Visual sentiment breakdown
- **Legend**: Shows color meanings
- **Auto-hide**: Empty categories don't show

### Trend Chart
- **Tap dots**: See date and sentiment
- **Toggle period**: Switch between 7D/30D
- **Zoom**: Pinch to zoom (if enabled)
- **Scroll**: Swipe to pan timeline

### Bar Chart
- **Tap bars**: View exact count
- **Compare**: See relative frequencies
- **Emoji display**: X-axis shows actual emojis

---

## Technical Details

### Chart Library

Uses **fl_chart** (v0.69.0+):
- High-performance charting
- Smooth animations
- Touch interactions
- Customizable styling

### Data Processing

**Pie Chart**:
- Counts entries by sentiment category
- Calculates percentages
- Filters zero-value segments

**Trend Chart**:
- Groups entries by date
- Calculates daily average sentiment
- Interpolates missing days
- Supports 7-day and 30-day windows

**Bar Chart**:
- Counts emoji usage frequency
- Sorts by frequency (descending)
- Shows top 8 most-used
- Maps emojis to sentiment colors

### Performance

- **Optimized rendering**: Charts only redraw when data changes
- **Efficient calculations**: Performed once per data load
- **Lazy loading**: Charts build on-demand
- **Memory efficient**: Limited data points displayed

---

## Chart Customization

### Colors

Charts follow app theme:
- **Positive**: Green (#4CAF50)
- **Neutral**: Orange (#FF9800)
- **Negative**: Red (#F44336)
- **Primary**: Purple (#6C63FF)

### Responsive Design

Charts adapt to:
- Screen size
- Orientation changes
- Theme changes (light/dark)
- Data volume

---

## Empty States

When no data is available:
- Pie Chart: Shows "No data to display"
- Trend Chart: Shows "Not enough data for trend analysis"
- Bar Chart: Shows "No data to display"

---

## Future Enhancements

Potential additions:
- Calendar heatmap view
- Weekly/monthly comparison
- Streak tracking visualization
- Export charts as images
- More detailed tooltips
- Custom date range selector
- Multiple mood comparison
- Annotation support for events

---

## Tips for Best Results

1. **Consistency**: Log moods daily for better trends
2. **Variety**: Use all available emojis naturally
3. **Honesty**: Track true feelings, not desired ones
4. **Regularity**: Same time each day helps patterns
5. **Context**: Add notes to understand chart patterns

---

## Troubleshooting

**Charts not showing?**
- Ensure you have mood entries logged
- Try refreshing the analytics screen
- Check if data loaded successfully

**Incorrect data?**
- Verify entries in History tab
- Check entry dates are correct
- Reload mood entries

**Performance issues?**
- Reduce displayed period (7D instead of 30D)
- Clear old entries if thousands exist
- Restart app if sluggish

---

## Chart Widget Files

Technical reference for developers:

```
lib/widgets/
├── sentiment_pie_chart.dart      # Pie chart for sentiment distribution
├── mood_trend_chart.dart         # Line chart for mood trends
└── emoji_frequency_chart.dart    # Bar chart for emoji usage
```

---

## Accessibility

Charts include:
- Semantic labels
- Touch tooltips
- High contrast colors
- Clear legends
- Text alternatives

---

**Enjoy your enhanced analytics!** 📊

Use these charts to gain insights into your emotional patterns and track your wellness journey visually.
